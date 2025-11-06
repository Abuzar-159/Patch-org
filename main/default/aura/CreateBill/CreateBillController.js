({
    doInit : function(component, event, helper){  
        helper.fetchcurrency(component, event, helper);
        if(component.get('v.recordId') !=undefined && component.get('v.recordId') !=null && component.get('v.recordId') != ''){
            helper.getBillDetails(component, event, helper);
        }
        var isAttRequired=$A.get("$Label.c.isCreateBillAttRequired");
        if(isAttRequired ==='true'){                    
            component.set("v.isAttRequired",true);
        }else{
            component.set("v.isAttRequired",false);
        }
        if(component.get("v.isMultiPOBill")){
            $A.enqueueAction(component.get("c.fetchMultiPoli"));
        }
        if(component.get('v.pId') !=undefined && component.get('v.pId') !=null && component.get('v.pId') != ''){
            
            var pId=component.get('v.pId');
            component.set('v.Bill.ERP7__Purchase_Order__c',pId);
            //$A.enqueueAction(component.get("c.fetchPoli"));
            
            var isMulticurrency = component.get('v.isMultiCurrency');
            if(isMulticurrency == true) { 
                helper.fetchPOCurrncy(component,event,helper); 
            }
        }
        if(component.get("v.ProjId") != null && component.get("v.ProjId") != undefined && component.get("v.ProjId") != ""){
            component.set("v.Bill.ERP7__Project__c", component.get("v.ProjId"));
        }
        if(component.get('v.vId') !=undefined && component.get('v.vId') !=null && component.get('v.vId') != ''){
            component.set('v.Bill.ERP7__Vendor__c',component.get("v.vId"));
            $A.enqueueAction(component.get("c.fetchVendorDetails"));
        }
        var billPo=component.get("v.Bill.ERP7__Purchase_Order__c");
        //alert(component.get("v.Bill.ERP7__Purchase_Order__c"));
        if(billPo!=undefined && billPo!=null && billPo!=''){
            
            var isMulticurrencyEnabled = component.get('v.isMultiCurrency');
            if(isMulticurrencyEnabled == true) { 
                helper.fetchPOCurrncy(component,event,helper); 
            }
        }
        //var org=JSON.stringify(component.get('v.pId').ERP7__Organisation__c);
        //component.set('v.Bill.ERP7__Organisation__c',org);
        let Itemtype = component.get("c.getpicklist"); 
        Itemtype.setParams({"sObject_Type":'ERP7__Bill_Line_Item__c',"Field":'ERP7__Item_Type__c'});
        Itemtype.setCallback(this,function(response){
            if(component.get('v.recordId') == undefined || component.get('v.recordId') == null || component.get('v.recordId') == ''){
                var po=component.get('v.Bill.ERP7__Purchase_Order__c');
                if(po!=undefined && po!=null && po!=''){
                    component.set('v.setRT','PO Bill');
                    component.set('v.ShowBillType',false);
                    component.set('v.showPage',true);
                }else{
                    if(component.get("v.isMultiPOBill")==false){
                        component.set('v.ShowBillType',true);
                        component.set('v.showPage',false);
                    }
                }  
            }
            component.set("v.Itemtype",response.getReturnValue());            
        });
        $A.enqueueAction(Itemtype);
        let Expensetype = component.get("c.getpicklist");
        Expensetype.setParams({"sObject_Type":'ERP7__Bill_Line_Item__c',"Field":'ERP7__Expense_Type__c'});
        Expensetype.setCallback(this,function(response){
            component.set("v.Expensetype",response.getReturnValue()); 
            //component.set("v.Bill.ERP7__TDS_Amount__c",0);
            // component.set("v.Bill.ERP7__Discount_Amount__c",0);
            //component.set("v.Bill.ERP7__VAT_TAX_Amount__c",0);    
            //var venId = component.get('v.Bill.ERP7__Vendor__r.Id');    
            //component.set('v.Bill.ERP7__Vendor__c',venId);
        });
        $A.enqueueAction(Expensetype);
        
        try{
            let BillFC = component.get("c.getBillFC");
            BillFC.setCallback(this,function(response){
                console.log('state getBillFC~>'+response.getState());
                if(response.getState() === 'SUCCESS'){
                    console.log('getBillFC resp~>',response.getReturnValue());
                    component.set("v.showAllocations", response.getReturnValue().AllocationAccess);
                    component.set("v.SyncSalesforce", response.getReturnValue().SalesFile);
                    component.set("v.isGDrive", response.getReturnValue().DriveFile);
                    component.set("v.SyncGDrive", response.getReturnValue().DriveFile);
                    component.set("v.standOrder", response.getReturnValue().stdOrder);
                    component.set("v.displayName", response.getReturnValue().displayName);
                    component.set("v.showVenName", response.getReturnValue().showVenCode);
                    component.set("v.showProdCode", response.getReturnValue().showProdCode);
                    component.set("v.ProjectAccess", response.getReturnValue().ProjectOnBillScreen);
                    component.set("v.DepartmentAccess", response.getReturnValue().DepartmentOnBillScreen);
                    
                }else{
                    console.log('Error:',response.getError());
                }
            });
            $A.enqueueAction(BillFC);
        }catch(e){ console.log('ee',e); }
        
         // Fetch the "Read Bill OCR" checkbox value
    const action = component.get("c.getReadBillOCRState");
    action.setCallback(this, function (response) {
        if (response.getState() === "SUCCESS") {
            component.set("v.isReadBillChecked", response.getReturnValue());
            console.log('isReadBillChecked: ',component.get("v.isReadBillChecked"));
        } else {
            console.error("Failed to fetch Read Bill OCR state.");
        }
    });
    $A.enqueueAction(action);
     if(component.get('v.pId') !=undefined && component.get('v.pId') !=null && component.get('v.pId') != '')$A.enqueueAction(component.get("c.fetchPoli"));    
        
        helper.FieldAccess(component, event);
        /*var files = [];
        files = component.get("v.FileList");
        if(files!=null && files!=''){
            $A.enqueueAction(component.get("c.handleFilesChange"));
        }*/
    },
    
    fetch_vendor_details: function(component, event, helper){
        if(component.get('v.recordId') == null || component.get('v.recordId') == '' || component.get('v.recordId') == undefined){
            var action = component.get('c.fetchvendordetails');
            action.setParams({
                VendorId : component.get("v.Bill.ERP7__Vendor__c"),
                bill_number : component.get("v.Bill.ERP7__Vendor_Bill_Number__c")
            });    
            action.setCallback(this, function(response){
                var state = response.getState();
                if( state === "SUCCESS" ){
                    if(response.getReturnValue()==true)
                        alert($A.get('$Label.c.Bill_with_this_Vendor_Bill_Number_already_exist'));
                }
            });
            $A.enqueueAction(action);
        }
    },
    
   updateTotalDiscount : function(c, e, h){
        console.log('updateTotalDiscount');
        var items=c.get('v.billItems');
        if($A.util.isUndefined(items.length)){
            var dis=items.ERP7__Discount__c;
            c.set("v.Bill.ERP7__Discount_Amount__c",dis);
        }else{
            var dis=0;
            for(var x in items){
                if(items[x].ERP7__Discount__c!=undefined && items[x].ERP7__Discount__c!=''){
                    var discount = items[x].ERP7__Discount__c;
                    dis=dis+discount*1;   
                }
                
            }
            c.set("v.Bill.ERP7__Discount_Amount__c",dis);
        }
    }, 
    
    updateTotalTax : function(c, e, h){
        try{
            console.log('updateTotalTax called');
            var items=c.get('v.billItems');
            console.log('items~>',JSON.stringify(items));
            
            if(items.ERP7__Tax_Rate__c==undefined)items.ERP7__Tax_Rate__c=0;
            if(items.ERP7__Other_Tax_Rate__c==undefined)items.ERP7__Other_Tax_Rate__c=0;
            if(items.ERP7__Quantity__c==undefined)items.ERP7__Quantity__c=0;
            if(items.ERP7__Amount__c==undefined)items.ERP7__Amount__c=0;
            console.log('updateTotalTax set1 items~>',JSON.stringify(items));
            
            //Moin commented this on 13th september 2023
           // /*for(var x in items){
              //  if(items[x].ERP7__Amount__c==undefined)items[x].ERP7__Amount__c=0;
                //if(items[x].ERP7__Other_Tax_Rate__c==undefined)items[x].ERP7__Other_Tax_Rate__c=0;
               // if(items[x].ERP7__Tax_Rate__c==undefined)items[x].ERP7__Tax_Rate__c=0;
                //if(items[x].ERP7__Quantity__c==undefined)items[x].ERP7__Quantity__c=0;
            //}
            
            //Moin added this
            //
            //for (var x in items) {
              //  items[x].ERP7__Amount__c = items[x].ERP7__Amount__c || 0;
               // items[x].ERP7__Other_Tax_Rate__c = items[x].ERP7__Other_Tax_Rate__c || 0;
                //items[x].ERP7__Tax_Rate__c = items[x].ERP7__Tax_Rate__c || 0;
                //items[x].ERP7__Quantity__c = items[x].ERP7__Quantity__c || 0;
         //   }
            
            for (var i = 0; i < items.length; i++) {
                var item = items[i];
                item.ERP7__Amount__c = item.ERP7__Amount__c || 0;
                item.ERP7__Other_Tax_Rate__c = item.ERP7__Other_Tax_Rate__c || 0;
                item.ERP7__Tax_Rate__c = item.ERP7__Tax_Rate__c || 0;
                item.ERP7__Quantity__c = item.ERP7__Quantity__c || 0;
                item.ERP7__Tax_Amount__c = item.ERP7__Tax_Amount__c || 0;
                item.ERP7__Total_Amount__c = item.ERP7__Total_Amount__c || 0;
            }
            console.log('updateTotalTax set2 items~>',JSON.stringify(items));
            if($A.util.isUndefined(items.length)){
                var tax=((items.ERP7__Total_Amount__c)/100)*items.ERP7__Tax_Rate__c;
                var OTtax=(items.ERP7__Amount__c/100)*items.ERP7__Other_Tax_Rate__c;
                var totalTax=(tax+OTtax)*items.ERP7__Quantity__c;
                c.set("v.Bill.ERP7__VAT_TAX_Amount__c",totalTax);
                console.log('updateTotalTax set3 items~>',JSON.stringify(items));
            }else{
                var totaltax=0;
                var tax = 0;
                var OTtax = 0;
                for (var i = 0; i < items.length; i++) {
                	var item = items[i];
                    item.ERP7__Amount__c = item.ERP7__Amount__c || 0;
                    item.ERP7__Tax_Amount__c = item.ERP7__Tax_Amount__c || 0;
                    item.ERP7__Other_Tax_Rate__c = item.ERP7__Other_Tax_Rate__c || 0;
                    tax = parseFloat(item.ERP7__Tax_Amount__c);
                    OTtax = parseFloat((item.ERP7__Amount__c/100)) * parseFloat(item.ERP7__Other_Tax_Rate__c); // Shaguftha M - 15_04_24 added parseFloat on the other tax rate as it was add the other tax rate as string for example if tax amount is 2 and other as 0 then as 20 so added parsefloat
                    totaltax += parseFloat(tax+OTtax);
                //for(var x in items){
                    //Moin commented this 0n 13th september 2023
                    //if($A.util.isEmpty(items[x].ERP7__Tax_Amount__c) || $A.util.isUndefinedOrNull(items[x].ERP7__Tax_Amount__c)) items[x].ERP7__Tax_Amount__c=0;
                    //if($A.util.isEmpty(items[x].ERP7__Amount__c) || $A.util.isUndefinedOrNull(items[x].ERP7__Amount__c)) items[x].ERP7__Amount__c=0;
                    //if($A.util.isEmpty(items[x].ERP7__Other_Tax_Rate__c) || $A.util.isUndefinedOrNull(items[x].ERP7__Other_Tax_Rate__c)) items[x].ERP7__Other_Tax_Rate__c=0;
                    //tax = items[x].ERP7__Tax_Amount__c;
                    //OTtax = parseFloat((items[x].ERP7__Amount__c/100) * items[x].ERP7__Other_Tax_Rate__c);
                    //totaltax += parseFloat(tax+OTtax);
                }
                console.log('totaltax~>'+totaltax);
                //if(totaltax >= 0 ) totaltax = totaltax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                c.set("v.Bill.ERP7__VAT_TAX_Amount__c",totaltax);
            }
        }catch(e){ console.log('updateTotalTax err '+e); }
    },
    
    updateTotalPrice: function(c, e, h) {
        try{
            console.log('updateTotalPrice called');
            var items=c.get('v.billItems');
            if($A.util.isUndefined(items.length)){
                var amt=items.ERP7__Quantity__c * items.ERP7__Amount__c;
                c.set("v.Bill.ERP7__Amount__c",amt);//amt.toFixed($A.get("$Label.c.DecimalPlacestoFixed"))
            }else{ 
                var amt=0;
                for (var i = 0; i < items.length; i++) {
                    //Moin commented on 13th september
                    //if($A.util.isEmpty(items[x].ERP7__Amount__c) || $A.util.isUndefinedOrNull(items[x].ERP7__Amount__c)) items[x].ERP7__Amount__c=0;
                    //if($A.util.isEmpty(items[x].ERP7__Quantity__c) || $A.util.isUndefinedOrNull(items[x].ERP7__Quantity__c)) items[x].ERP7__Quantity__c=0;
                    var item = items[i];
                    item.ERP7__Amount__c = item.ERP7__Amount__c || 0;
                    item.ERP7__Quantity__c = item.ERP7__Quantity__c || 0;
                    amt += parseFloat(item.ERP7__Quantity__c * item.ERP7__Amount__c);
                }
                //if(amt >= 0) amt = amt.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                c.set("v.Bill.ERP7__Amount__c",amt);
            }
        }catch(e){ console.log('updateTotalPrice err '+e); }
    },
    //added changes on this method on 13th sept 2023 for name or id setting.
    updateProduct: function(c, e, h) {
        try {
            console.log('updateProduct called');
            
            // Get the new value of the Product attribute
            var productName = c.get('v.Product');
            
            // Check if the product name is valid or assign a default value
            if ($A.util.isEmpty(productName)) {
                console.log('Product name is empty or undefined. Assigning default value.');
                productName = 'Default Product Name';
                c.set('v.Product', productName);
            }
            
            console.log('Updated Product Name:', productName);
    
            // Perform additional logic if necessary, e.g., updating related components or attributes
            // Example:
            // c.set("v.someOtherAttribute", "Updated based on Product change");
    
        } catch (err) {
            console.error('Error in updateProduct:', err);
        }
    },

    updateProductField: function (component, event, helper) {
    try {
        console.log("updateProductField called");
        var items = c.get("v.billItems"); // Retrieve the bill items
        var productId = c.get("v.Bill.ERP7__Product__c"); // Get the Product ID from the Bill object

        if ($A.util.isUndefinedOrNull(items) || items.length === 0) {
            console.warn("No bill items found to update.");
            return;
        }

        // Loop through each item and update the Product field
        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            item.ERP7__Product__c = productId; // Update the `ERP7__Product__c` field with productId

            // Log for debugging
            console.log(`Updated Item ${i + 1}:`, JSON.stringify(item));
        }

        // Update the billItems attribute with the modified list
        c.set("v.billItems", items);
        console.log("Product field updated successfully for all items.");
    } catch (e) {
        console.error("Error in updateProductField:", e);
    }
},  
    
    
   /* updateTotalDiscount: function (c, e, h) {
        console.log('updateTotalDiscount');
        var items = c.get('v.billItems');
        if ($A.util.isUndefined(items.length)) {
            var dis = items.ERP7__Discount__c || 0;
            c.set("v.Bill.ERP7__Discount_Amount__c", dis);
        } else {
            var dis = 0;
            for (var x in items) {
                if (
                    !$A.util.isEmpty(items[x].ERP7__Discount__c) &&
                    !$A.util.isUndefinedOrNull(items[x].ERP7__Discount__c)
                ) {
                    var discount = items[x].ERP7__Discount__c;
                    dis += discount * 1;
                }
            }
            c.set("v.Bill.ERP7__Discount_Amount__c", dis);
        }
    },

    updateTotalTax: function (c, e, h) {
        try {
            console.log('updateTotalTax called');
            var items = c.get('v.billItems');
            if (!items || items.length === 0) {
                console.warn('No bill items to process.');
                return;
            }

            for (var i = 0; i < items.length; i++) {
                var item = items[i];
                item.ERP7__Amount__c = item.ERP7__Amount__c || 0;
                item.ERP7__Other_Tax_Rate__c = item.ERP7__Other_Tax_Rate__c || 0;
                item.ERP7__Tax_Rate__c = item.ERP7__Tax_Rate__c || 0;
                item.ERP7__Quantity__c = item.ERP7__Quantity__c || 0;
                item.ERP7__Tax_Amount__c = item.ERP7__Tax_Amount__c || 0;

                // Check for Product__r and Product__r.Name, fallback to default value
                if (!$A.util.isEmpty(item.ERP7__Product__c)) {
                    // Product__c is already populated
                } else if (item.ERP7__Product__r && !$A.util.isEmpty(item.ERP7__Product__r.Name)) {
                    item.ERP7__Product__c = item.ERP7__Product__r.Name;
                } else {
                    item.ERP7__Product__c = "Default Product";
                }
            }

            var totaltax = 0;
            for (var i = 0; i < items.length; i++) {
                var item = items[i];
                var tax = parseFloat(item.ERP7__Tax_Amount__c || 0);
                var OTtax = parseFloat((item.ERP7__Amount__c / 100) * (item.ERP7__Other_Tax_Rate__c || 0));
                totaltax += parseFloat(tax + OTtax);
            }
            c.set("v.Bill.ERP7__VAT_TAX_Amount__c", totaltax);
        } catch (e) {
            console.error('Error in updateTotalTax:', e);
        }
    },

    updateTotalPrice: function (c, e, h) {
        try {
            console.log('updateTotalPrice called');
            var items = c.get('v.billItems');
            if ($A.util.isUndefined(items.length)) {
                var amt = items.ERP7__Quantity__c * items.ERP7__Amount__c;
                c.set("v.Bill.ERP7__Amount__c", amt);
            } else {
                var amt = 0;
                for (var i = 0; i < items.length; i++) {
                    var item = items[i];
                    item.ERP7__Amount__c = item.ERP7__Amount__c || 0;
                    item.ERP7__Quantity__c = item.ERP7__Quantity__c || 0;

                    // Check for Product__r and Product__r.Name, fallback to default value
                    if (!$A.util.isEmpty(item.ERP7__Product__c)) {
                        // Product__c is already populated
                    } else if (item.ERP7__Product__r && !$A.util.isEmpty(item.ERP7__Product__r.Name)) {
                        item.ERP7__Product__c = item.ERP7__Product__r.Name;
                    } else {
                        item.ERP7__Product__c = "Default Product";
                    }

                    amt += item.ERP7__Quantity__c * item.ERP7__Amount__c;
                }
                c.set("v.Bill.ERP7__Amount__c", amt);
            }
        } catch (e) {
            console.error('Error in updateTotalPrice:', e);
        }
    },
    
    updateProductField: function (c, e, h) {
        try {
            console.log("updateProductField called");
            var items = c.get("v.billItems"); // Retrieve the bill items
            var productId = c.get("v.Product"); // Get the Product field from the component

            if ($A.util.isUndefinedOrNull(items) || items.length === 0) {
                console.warn("No bill items found to update.");
                return;
            }

            // Loop through each item and update the Product field
            for (var i = 0; i < items.length; i++) {
                var item = items[i];

                // Ensure Product field is not blank
                if (!$A.util.isEmpty(productId)) {
                    item.ERP7__Product__c = productId; // Update the `ERP7__Product__c` field with productId
                } else if (item.ERP7__Product__r && !$A.util.isEmpty(item.ERP7__Product__r.Name)) {
                    item.ERP7__Product__c = item.ERP7__Product__r.Name; // Fall back to the product's name
                } else {
                    item.ERP7__Product__c = "Default Product"; // Fallback to default product name
                }

                // Log for debugging
                console.log(`Updated Item ${i + 1}:`, JSON.stringify(item));
            }

            // Update the billItems attribute with the modified list
            c.set("v.billItems", items);
            console.log("Product field updated successfully for all items.");
        } catch (e) {
            console.error("Error in updateProductField:", e);
        }
    }, */
    
    handleCheckSalesforce : function(component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        component.set("v.SyncSalesforce", isChecked);
    },
    
    handleCheckGDrive : function(component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        component.set("v.SyncGDrive", isChecked);
    },


     closePopup : function(component, event, helper) {
        component.set("v.showPopup", false);
    },

 
    
    saveBill : function(component, event, helper) {
        
        // ✅ Unknown products (not in PO)
        const prokeyval = component.get("v.productKeyIdListTrue");
        var unknownProducts = component.get("v.productKeyIdList") || [];
        
        // ✅ Extra qty products
        var extraQtyProducts = component.get("v.extraQtyProducts") || [];
        
        if ((prokeyval && unknownProducts.length > 0) || extraQtyProducts.length > 0) {
            var extractedItems = component.get("v.extractedItems") || [];
            var popupProducts = [];
            
            // 🔹 Case 1: Unknown products
            unknownProducts.forEach(function (prod) {
                var matchRow = extractedItems.find(function (row) {
                    return row.productName === prod.keyName;
                });
                
                var qty = matchRow ? matchRow.quantity : 0;
                var price = matchRow ? matchRow.unitPrice : 0;
                
                popupProducts.push({
                    productName: prod.keyName,
                    quantity: qty,
                    unitPrice: price
                });
            });
            
            // 🔹 Case 2: Extra qty products
            extraQtyProducts.forEach(function (prod) {
                popupProducts.push({
                    productName: prod.productName,
                    quantity: prod.extraQty,
                    unitPrice: prod.unitPrice
                });
            });
            
            // ✅ Collect Vendor Info
            var vendorInfo = {
                vendor: component.get("v.Bill.ERP7__Vendor__c"),
                vendorContact: component.get("v.Bill.ERP7__Vendor_Contact__c"),
                vendorAddress: component.get("v.Bill.ERP7__Vendor_Address__c"),
                description: 'This purchase is made from OCR Process for the products which is not being mentioned in the previouse Purchase Order while creating a bill.'
                
            };
            
            // ✅ Apex call → resolve Product Ids
            var action = component.get("c.getProductIdsByNamesNew");
            var productNames = popupProducts.map(function (p) {
                return p.productName;
            });
            
            action.setParams({ pname: productNames });
            
            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    var nameIdMap = response.getReturnValue(); // { "ProdName" : "Id" }
                    
                    // 🔹 Build final products list
                    var finalProducts = popupProducts.map(function (p) {
                        return {
                            productId: nameIdMap[p.productName] || null, // only Id if found
                            productName: p.productName,                  // always keep name
                            quantity: p.quantity,
                            unitPrice: p.unitPrice
                        };
                    });
                    
                    // 🔹 Build full payload
                    var billPayload = {
                        vendorInfo: vendorInfo,
                        products: finalProducts
                    };
                    
                    // Save for UI + Next Step
                    component.set("v.popupProducts", popupProducts); // table data
                    component.set("v.billPayload", billPayload);     // full payload
                    component.set("v.showPopup", true);
                    
                    console.log("✅ Bill Payload => ", JSON.stringify(billPayload));
                } else {
                    console.error("❌ Error fetching product Ids", response.getError());
                }
            });
            
            $A.enqueueAction(action);
        }
        
        
        else{
            // rest will be samw 
            
            
            try{
                component.set("v.showMmainSpin",true);
                console.log('Save Bill button called before if');
                if(component.get('v.setRT')=='PO Bill' && (component.get('v.recordId') ==undefined || component.get('v.recordId')==null || component.get('v.recordId') == '')){
                    var poliids = [];
                    if(component.get("v.Bill.ERP7__Purchase_Order__c") != undefined && component.get("v.Bill.ERP7__Purchase_Order__c") != null && component.get("v.Bill.ERP7__Purchase_Order__c") != ''){
                        poliids.push(component.get("v.Bill.ERP7__Purchase_Order__c"));
                    }
                    console.log('Save Bill button called before line 443');
                    if(component.get("v.isMultiPOBill")){
                        poliids = component.get("v.POIdsList");
                        console.log('Save Bill button -- called inside the if statement');
                        
                        console.log('POIdsList:', poliids);
                    }
                    console.log('Save Bill button called before state responce');
                    
                    var fetchpoliAction = component.get("c.fetch_Polis_bill");
                    fetchpoliAction.setParams({"poId":poliids,BillId:component.get('v.recordId')});
                    fetchpoliAction.setCallback(this,function(response){
                        if(response.getState() === 'SUCCESS'){
                            //component.set("v.showMmainSpin",false);
                            console.log('Save Bill button called before state responce');
                            var resultList = response.getReturnValue();
                            if(resultList.length > 0 ){//|| component.get("v.isMultiPOBill")
                                var poliList = [];
                                //if(!component.get("v.isMultiPOBill")) poliList = JSON.parse(resultList[1]);
                                poliList = JSON.parse(resultList[1]);
                                console.log('Save Bill button called before 456 line');
                                if(!$A.util.isEmpty(poliList)){// || component.get("v.isMultiPOBill")
                                    console.log('saveBill called');
                                    
                                    var billList = component.get("v.billItems");
                                    var Billobj = component.get("v.Bill");
                                    
                                    //alert('Bill=>'+JSON.stringify(component.get("v.Bill")));
                                    Billobj.ERP7__Vendor_Contact__r = null;
                                    Billobj.ERP7__Vendor_Address__r = null;
                                    Billobj.ERP7__Purchase_Order__r = null;
                                    Billobj.ERP7__Sales_Order__r = null;
                                    Billobj.ERP7__Posted__c = component.get('v.setBillPost');
                                    if(Billobj.ERP7__Total_Amount__c == undefined || Billobj.ERP7__Total_Amount__c == null || Billobj.ERP7__Total_Amount__c == '') Billobj.ERP7__Total_Amount__c = 0.00;
                                    
                                    var totalAmount=parseFloat(Billobj.ERP7__Amount__c);
                                    var advAmount=component.get('v.advPayment');
                                    console.log('Save Bill button called before helper');
                                    if(component.get('v.setRT')=='Advance to vendor'){
                                        var amount1=component.find('amount1').get('v.value');
                                        if(parseFloat(amount1) <= 0 || amount1 ==''){
                                            
                                            
                                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_enter_a_valid_amount'));
                                            console.log('Save Bill button called line 477');
                                            
                                            component.set("v.showMmainSpin",false);
                                            
                                            return;
                                        }            
                                        /*if(amount1 == (totalAmount-advAmount)){
                    helper.showToast('Error!','error','You are creating bill for full amount, Please create a purchase order bill');
                    return;
                }*/
                                        if(amount1 > (totalAmount-advAmount)){
                                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Can_not_enter_more_than_todal_due_amount'));
                                            component.set("v.showMmainSpin",false);
                                            return;
                                        }
                                        Billobj.ERP7__Amount__c=amount1;
                                    }else{
                                        Billobj.ERP7__Amount__c-=advAmount;
                                    }
                                    //component.set("v.showMmainSpin",false);
                                    component.NOerrors =  true;
                                    helper.validation_Check(component,event);
                                    
                                             
                                    
                                    var isErrorsAA = helper.AnalyticalAccountCheck(component, event, helper); 
                                    var isErrorsAACOA = helper.AnalyticalAccountCoaCheck(component, event, helper); 
                                    
                                    if(component.get("v.showAllocations")){
                                        var accCheck =true;
                                        accCheck = helper.AnalyticalAccountingAccountCheck(component, event, helper);
                                        console.log('accCheck: '+accCheck);
                                        if(!accCheck){
                                            component.set("v.showMmainSpin",false);
                                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.AddAnalyticalAccount'));
                                            return;
                                        }
                                    }
                                    
                                    if(component.NOerrors){
                                        var showError=false;
                                        
                                        if(billList.length>0){
                                            for(var a = 0; a < billList.length; a++){//Moin added this on 13th september
                                                if(billList[a].ERP7__Product__r != null && billList[a].ERP7__Product__r != undefined && billList[a].ERP7__Product__r != '') delete billList[a].ERP7__Product__r;
                                                //for(var a in billList ){
                                                if(component.get("v.isMultiCurrency")) billList[a].CurrencyIsoCode = component.get("v.Bill.CurrencyIsoCode");
                                                if(component.get("v.fromPortal") == false){ //change arshad
                                                    if(billList[a].ERP7__Chart_Of_Account__c=='' || billList[a].ERP7__Chart_Of_Account__c==null || billList[a].ERP7__Chart_Of_Account__c==undefined){
                                                        showError=true;
                                                        var po=component.get('v.Bill.ERP7__Purchase_Order__c');
                                                        if(po!=null && po!='' && po!=undefined) helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_Select_the_inventory_account_for_all_line_items'));
                                                        else helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Please_Select_the_expense_account_for_all_line_items'));
                                                    }
                                                }
                                            }
                                        }
                                        // component.set("v.showMmainSpin",false);
                                        // if($A.util.isUndefinedOrNull(component.get("v.Bill.ERP7__Vendor_Bill_Number__c"))){
                                        //     helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_Enter_the_Vendor_Bill_Number'));
                                        //     component.set("v.showMmainSpin",false);
                                        //     return;
                                        // }

                                            // added changes by Saqlain on 4th Nov 2025 , to check vendor bill number is empty or not
                                        component.set("v.showMmainSpin", false);
                                        console.log('Save Bill button called line 603 before Vendor Bill Number check');

                                        const bill = component.get("v.Bill");
                                        const rawVbn = bill && bill.ERP7__Vendor_Bill_Number__c;

                                        console.log(`Vendor Bill Number (raw): [${rawVbn}] type=${typeof rawVbn}`);

                                        const normalizedVbn = (typeof rawVbn === 'string') ? rawVbn.trim() : rawVbn;

                                        if ($A.util.isEmpty(normalizedVbn)) { // catches null, undefined, "" ; after trim also catches "   "
                                            console.warn("Vendor Bill Number missing/blank. Showing error toast…");

                                            helper.showToast(
                                                $A.get('$Label.c.Error_UsersShiftMatch'),
                                                'error',
                                                $A.get('$Label.c.Please_Enter_the_Vendor_Bill_Number')
                                            );

                                           
                                                component.set("v.showMmainSpin", false);
                                                console.log("Spinner hidden after timeout due to missing Vendor Bill Number.");
                                            return;
                                        }
                                        // end Saqlain changes
                                          var fillList11=component.get("v.fillList");



                                        //Moin removed and added below code if(component.get("v.recordId") != null && component.get("v.recordId") ==  undefined &&  component.get("v.recordId") ==  ''){
                                        if(component.get("v.recordId") != null && component.get("v.recordId") !=  undefined &&  component.get("v.recordId") !=  ''){
                                            if(component.get("v.isAttRequired") && (component.get("v.uploadedFile") == null || component.get("v.uploadedFile").length == 0) && component.get('v.setRT')!='Advance to vendor'){
                                                var fillList11=component.get("v.fillList");
                                                if(component.get("v.isAttRequired") && (component.find("fileId").get("v.files")==null || fillList11.length == 0) && component.get('v.setRT')!='Advance to vendor'){
                                                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Bill_Attachment_is_missing'));
                                                    component.set("v.showMmainSpin",false);
                                                    return;
                                                }
                                            }
                                            if(component.get("v.showAllocations")){
                                                var accCheck =true;
                                                accCheck = helper.AnalyticalAccountingAccountCheck(component, event, helper);
                                                console.log('accCheck ************************************************************: '+accCheck);
                                                if(!accCheck){
                                                    component.set("v.showMmainSpin",false);
                                                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.AddAnalyticalAccount'));
                                                    return;
                                                }
                                            }
                                            //Moin commented this
                                            /* 
                   else{
                       var fillList11=component.get("v.fillList");
                       if(component.get("v.isAttRequired") && (component.find("fileId").get("v.files")==null || fillList11.length == 0) && component.get('v.setRT')!='Advance to vendor'){
                           helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Bill_Attachment_is_missing'));
                           return;
                       }
                   }*/
                                    }
                                    else{
                                        var fillList11=component.get("v.fillList");
                                        if(component.get("v.isAttRequired") && (component.find("fileId").get("v.files")==null || fillList11.length == 0) && component.get('v.setRT')!='Advance to vendor'){
                                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Bill_Attachment_is_missing'));
                                            component.set("v.showMmainSpin",false);
                                            return;
                                        }
                                    }
                                    
                                    
                                    if(!component.get("v.SyncSalesforce") && !component.get("v.SyncGDrive") && component.get("v.isGDrive")){                
                                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Please Select Salesforce or Google Drive');
                                        component.set("v.showMmainSpin",false);
                                        return;
                                    }
                                    
                                    /* if(component.get("v.showAllocations")){
                                        var accCheck =true;
                                        accCheck = helper.AnalyticalAccountingAccountCheck(component, event, helper);
                                        console.log('accCheck: '+accCheck);
                                        if(!accCheck){
                                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.AddAnalyticalAccount'));
                                            return;
                                        }
                                    }*/


                                    console.log('Outside PO Bill tolernace');
                                    if(billList.length > 0 && !(showError) ){
                                        if(!isErrorsAA &&!isErrorsAACOA){
                                            var shouldValidate = (component.get('v.setRT') === 'PO Bill');
                                            if (shouldValidate) {
                                                console.log('Inside PO Bill');
                                                var billJson = JSON.stringify(component.get("v.billItems"));
                                                var poliJson = JSON.stringify(poliList);
                                                console.log('billJson~>', billJson);
                                                console.log('poliJson~>', poliJson);
                                                //var poliList = component.get("v.poLineItems"); // whatever list you already hold for PO lines
                                                
                                                var validateAction2 = component.get("c.validateBillToleranceJson");
                                                validateAction2.setParams({ billItemsJson: billJson, poliItemsJson: poliJson });
                                                
                                                validateAction2.setCallback(this, function(resp) {
                                                    if (resp.getState()  === "SUCCESS") {
                                                        console.log('resp.getState()', resp.getState());
                                                        var err = resp.getReturnValue(); // String or null
                                                        console.log('err', err);
                                                        if (err !=null) {
                                                            // ❌ Has tolerance issues → show and STOP. Do not clear Accounts.
                                                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), 'error', err);
                                                            component.set("v.showMmainSpin", false);
                                                            return;
                                                        }else{
                                                            // else{
                                                            console.log('Continued after Inside PO Bill?');
                                                            var dimensionList = [];
                                                            try{
                                                                
                                                                //for(var x in billList){
                                                                for(var x = 0; x < billList.length; x++){//Moin added this on 13th september
                                                                    if(billList[x].Accounts != undefined && billList[x].Accounts != null){
                                                                        if(billList[x].Accounts.length > 0){
                                                                            for(var y in billList[x].Accounts){
                                                                                if(billList[x].Accounts[y].ERP7__Sort_Order__c != undefined && billList[x].Accounts[y].ERP7__Sort_Order__c != null){
                                                                                    console.log('before poLIst['+x+'].Accounts['+y+'].ERP7__Sort_Order__c ~>'+billList[x].Accounts[y].ERP7__Sort_Order__c);
                                                                                    billList[x].Accounts[y].ERP7__Sort_Order__c = parseInt(parseInt(x)+1);
                                                                                    console.log('after poLIst['+x+'].Accounts['+y+'].ERP7__Sort_Order__c ~>'+billList[x].Accounts[y].ERP7__Sort_Order__c);
                                                                                }
                                                                            }
                                                                            dimensionList.push(billList[x].Accounts);
                                                                        }
                                                                    }
                                                                }
                                                                console.log('dimensionList : ',dimensionList);
                                                                
                                                                for(var x in billList){
                                                                    if(billList[x].Accounts != undefined && billList[x].Accounts != null) billList[x].Accounts = [];
                                                                    billList[x].projBudget = '';
                                                                    billList[x].projCommittedBudget = '';
                                                                    billList[x].projConsumedBudget = '';
                                                                    billList[x].projRemainingBudget = '';
                                                                }
                                                            }catch(e){
                                                                console.log('arshad err,',e);
                                                            }
                                                            // }
                                                            
                                                            component.set("v.showMmainSpin",true);
                                                            //Moin commented and added this on 31st july 2023
                                                            var saveAction = component.get("c.save_UpdatedBill");
                                                            //var saveAction = component.get("c.save_Bill");
                                                            console.log('JSON.stringify(Billobj)~>'+JSON.stringify(Billobj));
                                                            console.log('JSON.stringify(billList)~>'+JSON.stringify(billList));
                                                            
                                                            let jsonBill  = JSON.stringify(Billobj);
                                                            let jsonBillItems = JSON.stringify(billList);
                                                            var RTName;
                                                            if(component.get('v.setRT')=='PO Bill')RTName='PO_Bill';
                                                            if(component.get('v.setRT')=='Expense Bill')RTName='Expense_Bill';
                                                            if(component.get('v.setRT')=='Advance to vendor')RTName='Advance_to_vendor';
                                                            
                                                            console.log('saveBill v.clone~>'+component.get("v.clone"));
                                                            
                                                            saveAction.setParams({"Bill": jsonBill, "BillItems" :jsonBillItems,RTName:RTName,clone:component.get("v.clone")});
                                                            saveAction.setCallback(this,function(response){
                                                                try{
                                                                    if(response.getState() === 'SUCCESS'){ 
                                                                        console.log('success here 1 resp~>',JSON.stringify(response.getReturnValue()));
                                                                        var result = response.getReturnValue();
                                                                        
                                                                        if(!$A.util.isUndefinedOrNull(result['error'])) {
                                                                            console.log('here 5 ');
                                                                            helper.showToast('Error!','error',result['error']);
                                                                            component.set("v.showMmainSpin",false);
                                                                            return ;
                                                                        }
                                                                        
                                                                        var bilobj = result['bill']; 
                                                                        component.set("v.BillId",bilobj.Id);
                                                                        
                                                                        if(component.get("v.clone")){
                                                                            component.set("v.recordId", bilobj.Id);//Moin added this on 14th august 2023 if(component.get("v.clone")) 
                                                                            console.log('inhere1 clone true saveBill');
                                                                        }
                                                                        
                                                                        console.log('here 1.1 : ',bilobj.Id);
                                                                        console.log('setRT : ',component.get('v.setRT'));
                                                                        console.log('fillList11 :',fillList11);
                                                                        
                                                                        /* if(!$A.util.isUndefinedOrNull(result['error'])) {
                                                            console.log('here 5 ');
                                                            helper.showToast('Error!','error',result['error']);
                                                            component.set("v.showMmainSpin",false);
                                                            return ;
                                                        }*/
                                                                        
                                                                        //added by arshad 23 Aug 2023
                                                                        var hasAttachmentsToUpload = false;
                                                                        
                                                                        if(component.get('v.setRT')=='PO Bill' || component.get('v.setRT')=='Expense Bill' || component.get('v.setRT')=='Advance to vendor'){
                                                                            if(component.find("fileId").get("v.files")!=null){
                                                                                console.log('fileId get v.files not null');
                                                                                if (component.find("fileId").get("v.files").length > 0 && component.find("fileId").get("v.files") != undefined && fillList11.length > 0 && fillList11 != undefined) {   
                                                                                    console.log('fileId get v.files length > 0');
                                                                                    hasAttachmentsToUpload = true;
                                                                                    var fileInput = component.get("v.FileList");
                                                                                    for(var i=0; i<fileInput.length; i++){
                                                                                        if(!component.get("v.clone")) helper.saveAtt(component,event,fileInput[i],bilobj.Id);
                                                                                        else helper.saveCloneAtt(component,event,fileInput[i],bilobj.Id);
                                                                                    } 
                                                                                }else console.log('not going fileId get v.files length 0');
                                                                            }else console.log('not going fileId get v.files null');
                                                                            
                                                                            console.log('Attach : ',component.get("v.Attach"));
                                                                            if(component.get("v.Attach")!=null){
                                                                                console.log('save_attachment2 here 3 ');
                                                                                var Billobj = component.get("v.BillId");
                                                                                var action=component.get("c.save_attachment2");
                                                                                action.setParams({"parentId": Billobj,"Pid":component.get("v.Bill.ERP7__Purchase_Order__c"), });
                                                                                action.setCallback(this,function(response){
                                                                                    if(response.getState() === 'SUCCESS'){
                                                                                        console.log('save_attachment2 here 4 success');
                                                                                    }else{
                                                                                        var errors = response.getError();
                                                                                        console.log("server error in save_attachment2 : ", JSON.stringify(errors));
                                                                                    }
                                                                                });
                                                                                $A.enqueueAction(action);
                                                                            }
                                                                            //return;
                                                                        }
                                                                        
                                                                        console.log('dimensionList.length : ',dimensionList.length);
                                                                        if(dimensionList.length > 0){
                                                                            try{
                                                                                var action2=component.get("c.createDimensionsList");
                                                                                action2.setParams({'dimelist':JSON.stringify(dimensionList), 'BillId':bilobj.Id});
                                                                                action2.setCallback(this,function(response){
                                                                                    if(response.getState() === "SUCCESS"){
                                                                                        console.log('createDimensionsList in success');
                                                                                        //component.set("v.isMultiCurrency",response.getReturnValue().isMulticurrency);
                                                                                        //component.set("v.currencyList",response.getReturnValue().currencyList);
                                                                                    }else{
                                                                                        var errors = response.getError();
                                                                                        console.log("server error in dimelist : ", JSON.stringify(errors));
                                                                                    } 
                                                                                });
                                                                                $A.enqueueAction(action2);
                                                                            }catch(e){
                                                                                console.log('arshad err 2,',e);
                                                                            }
                                                                        }
                                                                        
                                                                        // return;
                                                                        if(component.get("v.recordId") != null && component.get("v.recordId") !=  undefined && component.get("v.recordId") !=  '' && !component.get("v.clone")){
                                                                            console.log('inhere if going to record page');
                                                                            var RecId = component.get("v.recordId");
                                                                            var RecUrl = "/lightning/r/ERP7__Bill__c/" + RecId + "/view";
                                                                            helper.showToast($A.get('$Label.c.Success'),'success', result['bill'].Id+' '+ $A.get('$Label.c.Bill_Updated_Successfully'));
                                                                            
                                                                            //added by arshad 23 Aug 2023
                                                                            if(!component.get("v.fromAP")){
                                                                                if(hasAttachmentsToUpload){
                                                                                    setTimeout(function(){ window.open(RecUrl,'_parent'); }, 5000);
                                                                                }else{
                                                                                    window.open(RecUrl,'_parent');
                                                                                }
                                                                            }
                                                                        }
                                                                        else{
                                                                            console.log('inhere else bcoz maybe clone true');
                                                                            helper.showToast($A.get('$Label.c.Success'),'success', result['bill'].Id+' '+ $A.get('$Label.c.Bill_Created_Successfully'));  
                                                                        }
                                                                        
                                                                        if(component.get("v.navigateToRecord")){
                                                                            console.log('inhere navigateToRecord true ');
                                                                            var navEvt = $A.get("e.force:navigateToSObject");
                                                                            if(navEvt != undefined){
                                                                                navEvt.setParams({
                                                                                    "isredirect": true,
                                                                                    "recordId": result['bill'].Id,
                                                                                    "slideDevName": "detail"
                                                                                }); 
                                                                                
                                                                                //added by arshad 23 Aug 2023
                                                                                if(hasAttachmentsToUpload){
                                                                                    setTimeout(function(){  navEvt.fire(); }, 5000);
                                                                                }else{
                                                                                    navEvt.fire();
                                                                                }
                                                                            }
                                                                            else {
                                                                                console.log('inhere window.location.replace');
                                                                                var selectedBillList=[];
                                                                                selectedBillList.push(result['bill'].Id);
                                                                                var url = '/'+result['bill'].Id;
                                                                                
                                                                                //added by arshad 23 Aug 2023
                                                                                if(hasAttachmentsToUpload){
                                                                                    setTimeout(function(){  window.location.replace(url); }, 5000);
                                                                                }else{
                                                                                    window.location.replace(url);
                                                                                }
                                                                            }
                                                                        }else if(component.get("v.fromProject")){
                                                                            var evt = $A.get("e.force:navigateToComponent");
                                                                            evt.setParams({
                                                                                componentDef : "c:Milestones",
                                                                                componentAttributes: {
                                                                                    "currentProj" : component.get("v.currentProj"),
                                                                                    "projectId" : component.get("v.ProjId"),
                                                                                    "newProj" : false
                                                                                }
                                                                            });
                                                                            evt.fire();
                                                                        }
                                                                            else{
                                                                                console.log('inhere navigateToRecord false');
                                                                                var selectedBillList=[];
                                                                                var result = response.getReturnValue(); 
                                                                                var bilobj = result['bill2'];
                                                                                var evt = $A.get("e.force:navigateToComponent");
                                                                                evt.setParams({
                                                                                    componentDef : "c:Accounts_Payable",
                                                                                    componentAttributes: {
                                                                                        "selectedTab" : 'Bills',
                                                                                        "setSearch" : bilobj.Name,
                                                                                    }
                                                                                });
                                                                                
                                                                                //added by arshad 23 Aug 2023
                                                                                if(hasAttachmentsToUpload){
                                                                                    setTimeout(function(){  evt.fire();  }, 5000);
                                                                                }else{
                                                                                    evt.fire(); 
                                                                                }
                                                                            }
                                                                        
                                                                        console.log('here 7');
                                                                        
                                                                        if(component.get("v.fromPortal")){
                                                                            //added by arshad 23 Aug 2023
                                                                            if(hasAttachmentsToUpload){
                                                                                setTimeout(function(){  location.reload();  }, 5000);
                                                                            }else{
                                                                                location.reload(); 
                                                                            }
                                                                        }
                                                                        
                                                                    }else{
                                                                        var errors = response.getError();
                                                                        console.log("server error in createBill : ", errors);
                                                                        try{
                                                                            if(errors != undefined && errors.length >0){
                                                                                let err = errors[0].message;
                                                                                helper.showToast('Error!','error', errors[0].message); 
                                                                            }
                                                                        }catch(e){ helper.showToast('Error!','error','Entries mismatch found!');  }
                                                                        
                                                                        component.set("v.showMmainSpin",false);
                                                                    }
                                                                    
                                                                }catch(e){
                                                                    console.log('error~>'+e);
                                                                    if(response.getState() === 'SUCCESS'){ 
                                                                        console.log('try error catch success so reloading if portalUser');
                                                                        if(component.get("v.fromPortal")){
                                                                            setTimeout(
                                                                                $A.getCallback(function() {
                                                                                    location.reload();
                                                                                }), 5000
                                                                            );
                                                                        }
                                                                    }else{
                                                                        var errors = response.getError();
                                                                        console.log("server error in createBill : ", errors);
                                                                        try{
                                                                            if(errors != undefined && errors.length >0){
                                                                                let err = errors[0].message;
                                                                                helper.showToast('Error!','error', errors[0].message); 
                                                                            }
                                                                        }catch(e){ helper.showToast('Error!','error','Entries mismatch found!');  }
                                                                        component.set("v.showMmainSpin",false);
                                                                    }
                                                                }
                                                                
                                                                //added by arshad 23 Aug 2023
                                                                if(hasAttachmentsToUpload){
                                                                    setTimeout(function(){   component.set("v.showMmainSpin",false);  }, 5000);
                                                                }else{
                                                                    component.set("v.showMmainSpin",false);
                                                                }
                                                                
                                                            });
                                                            $A.enqueueAction(saveAction);
                                                        }
                                                    }
                                                });
                                                $A.enqueueAction(validateAction2);
                                                return; // stop the else-branch flow here until validation returns
                                            }
                                            else{
                                                            // else{
                                                            console.log('Continued after Inside PO Bill?');
                                                            var dimensionList = [];
                                                            try{
                                                                
                                                                //for(var x in billList){
                                                                for(var x = 0; x < billList.length; x++){//Moin added this on 13th september
                                                                    if(billList[x].Accounts != undefined && billList[x].Accounts != null){
                                                                        if(billList[x].Accounts.length > 0){
                                                                            for(var y in billList[x].Accounts){
                                                                                if(billList[x].Accounts[y].ERP7__Sort_Order__c != undefined && billList[x].Accounts[y].ERP7__Sort_Order__c != null){
                                                                                    console.log('before poLIst['+x+'].Accounts['+y+'].ERP7__Sort_Order__c ~>'+billList[x].Accounts[y].ERP7__Sort_Order__c);
                                                                                    billList[x].Accounts[y].ERP7__Sort_Order__c = parseInt(parseInt(x)+1);
                                                                                    console.log('after poLIst['+x+'].Accounts['+y+'].ERP7__Sort_Order__c ~>'+billList[x].Accounts[y].ERP7__Sort_Order__c);
                                                                                }
                                                                            }
                                                                            dimensionList.push(billList[x].Accounts);
                                                                        }
                                                                    }
                                                                }
                                                                console.log('dimensionList : ',dimensionList);
                                                                
                                                                for(var x in billList){
                                                                    if(billList[x].Accounts != undefined && billList[x].Accounts != null) billList[x].Accounts = [];
                                                                    billList[x].projBudget = '';
                                                                    billList[x].projCommittedBudget = '';
                                                                    billList[x].projConsumedBudget = '';
                                                                    billList[x].projRemainingBudget = '';
                                                                }
                                                            }catch(e){
                                                                console.log('arshad err,',e);
                                                            }
                                                            // }
                                                            
                                                            component.set("v.showMmainSpin",true);
                                                            //Moin commented and added this on 31st july 2023
                                                            var saveAction = component.get("c.save_UpdatedBill");
                                                            //var saveAction = component.get("c.save_Bill");
                                                            console.log('JSON.stringify(Billobj)~>'+JSON.stringify(Billobj));
                                                            console.log('JSON.stringify(billList)~>'+JSON.stringify(billList));
                                                            
                                                            let jsonBill  = JSON.stringify(Billobj);
                                                            let jsonBillItems = JSON.stringify(billList);
                                                            var RTName;
                                                            if(component.get('v.setRT')=='PO Bill')RTName='PO_Bill';
                                                            if(component.get('v.setRT')=='Expense Bill')RTName='Expense_Bill';
                                                            if(component.get('v.setRT')=='Advance to vendor')RTName='Advance_to_vendor';
                                                            
                                                            console.log('saveBill v.clone~>'+component.get("v.clone"));
                                                            
                                                            saveAction.setParams({"Bill": jsonBill, "BillItems" :jsonBillItems,RTName:RTName,clone:component.get("v.clone")});
                                                            saveAction.setCallback(this,function(response){
                                                                try{
                                                                    if(response.getState() === 'SUCCESS'){ 
                                                                        console.log('success here 1 resp~>',JSON.stringify(response.getReturnValue()));
                                                                        var result = response.getReturnValue();
                                                                        
                                                                        if(!$A.util.isUndefinedOrNull(result['error'])) {
                                                                            console.log('here 5 ');
                                                                            helper.showToast('Error!','error',result['error']);
                                                                            component.set("v.showMmainSpin",false);
                                                                            return ;
                                                                        }
                                                                        
                                                                        var bilobj = result['bill']; 
                                                                        component.set("v.BillId",bilobj.Id);
                                                                        
                                                                        if(component.get("v.clone")){
                                                                            component.set("v.recordId", bilobj.Id);//Moin added this on 14th august 2023 if(component.get("v.clone")) 
                                                                            console.log('inhere1 clone true saveBill');
                                                                        }
                                                                        
                                                                        console.log('here 1.1 : ',bilobj.Id);
                                                                        console.log('setRT : ',component.get('v.setRT'));
                                                                        console.log('fillList11 :',fillList11);
                                                                        
                                                                        /* if(!$A.util.isUndefinedOrNull(result['error'])) {
                                                            console.log('here 5 ');
                                                            helper.showToast('Error!','error',result['error']);
                                                            component.set("v.showMmainSpin",false);
                                                            return ;
                                                        }*/
                                                                        
                                                                        //added by arshad 23 Aug 2023
                                                                        var hasAttachmentsToUpload = false;
                                                                        
                                                                        if(component.get('v.setRT')=='PO Bill' || component.get('v.setRT')=='Expense Bill' || component.get('v.setRT')=='Advance to vendor'){
                                                                            if(component.find("fileId").get("v.files")!=null){
                                                                                console.log('fileId get v.files not null');
                                                                                if (component.find("fileId").get("v.files").length > 0 && component.find("fileId").get("v.files") != undefined && fillList11.length > 0 && fillList11 != undefined) {   
                                                                                    console.log('fileId get v.files length > 0');
                                                                                    hasAttachmentsToUpload = true;
                                                                                    var fileInput = component.get("v.FileList");
                                                                                    for(var i=0; i<fileInput.length; i++){
                                                                                        if(!component.get("v.clone")) helper.saveAtt(component,event,fileInput[i],bilobj.Id);
                                                                                        else helper.saveCloneAtt(component,event,fileInput[i],bilobj.Id);
                                                                                    } 
                                                                                }else console.log('not going fileId get v.files length 0');
                                                                            }else console.log('not going fileId get v.files null');
                                                                            
                                                                            console.log('Attach : ',component.get("v.Attach"));
                                                                            if(component.get("v.Attach")!=null){
                                                                                console.log('save_attachment2 here 3 ');
                                                                                var Billobj = component.get("v.BillId");
                                                                                var action=component.get("c.save_attachment2");
                                                                                action.setParams({"parentId": Billobj,"Pid":component.get("v.Bill.ERP7__Purchase_Order__c"), });
                                                                                action.setCallback(this,function(response){
                                                                                    if(response.getState() === 'SUCCESS'){
                                                                                        console.log('save_attachment2 here 4 success');
                                                                                    }else{
                                                                                        var errors = response.getError();
                                                                                        console.log("server error in save_attachment2 : ", JSON.stringify(errors));
                                                                                    }
                                                                                });
                                                                                $A.enqueueAction(action);
                                                                            }
                                                                            //return;
                                                                        }
                                                                        
                                                                        console.log('dimensionList.length : ',dimensionList.length);
                                                                        if(dimensionList.length > 0){
                                                                            try{
                                                                                var action2=component.get("c.createDimensionsList");
                                                                                action2.setParams({'dimelist':JSON.stringify(dimensionList), 'BillId':bilobj.Id});
                                                                                action2.setCallback(this,function(response){
                                                                                    if(response.getState() === "SUCCESS"){
                                                                                        console.log('createDimensionsList in success');
                                                                                        //component.set("v.isMultiCurrency",response.getReturnValue().isMulticurrency);
                                                                                        //component.set("v.currencyList",response.getReturnValue().currencyList);
                                                                                    }else{
                                                                                        var errors = response.getError();
                                                                                        console.log("server error in dimelist : ", JSON.stringify(errors));
                                                                                    } 
                                                                                });
                                                                                $A.enqueueAction(action2);
                                                                            }catch(e){
                                                                                console.log('arshad err 2,',e);
                                                                            }
                                                                        }
                                                                        
                                                                        // return;
                                                                        if(component.get("v.recordId") != null && component.get("v.recordId") !=  undefined && component.get("v.recordId") !=  '' && !component.get("v.clone")){
                                                                            console.log('inhere if going to record page');
                                                                            var RecId = component.get("v.recordId");
                                                                            var RecUrl = "/lightning/r/ERP7__Bill__c/" + RecId + "/view";
                                                                            helper.showToast($A.get('$Label.c.Success'),'success', result['bill'].Id+' '+ $A.get('$Label.c.Bill_Updated_Successfully'));
                                                                            
                                                                            //added by arshad 23 Aug 2023
                                                                            if(!component.get("v.fromAP")){
                                                                                if(hasAttachmentsToUpload){
                                                                                    setTimeout(function(){ window.open(RecUrl,'_parent'); }, 5000);
                                                                                }else{
                                                                                    window.open(RecUrl,'_parent');
                                                                                }
                                                                            }
                                                                        }
                                                                        else{
                                                                            console.log('inhere else bcoz maybe clone true');
                                                                            helper.showToast($A.get('$Label.c.Success'),'success', result['bill'].Id+' '+ $A.get('$Label.c.Bill_Created_Successfully'));  
                                                                        }
                                                                        
                                                                        if(component.get("v.navigateToRecord")){
                                                                            console.log('inhere navigateToRecord true ');
                                                                            var navEvt = $A.get("e.force:navigateToSObject");
                                                                            if(navEvt != undefined){
                                                                                navEvt.setParams({
                                                                                    "isredirect": true,
                                                                                    "recordId": result['bill'].Id,
                                                                                    "slideDevName": "detail"
                                                                                }); 
                                                                                
                                                                                //added by arshad 23 Aug 2023
                                                                                if(hasAttachmentsToUpload){
                                                                                    setTimeout(function(){  navEvt.fire(); }, 5000);
                                                                                }else{
                                                                                    navEvt.fire();
                                                                                }
                                                                            }
                                                                            else {
                                                                                console.log('inhere window.location.replace');
                                                                                var selectedBillList=[];
                                                                                selectedBillList.push(result['bill'].Id);
                                                                                var url = '/'+result['bill'].Id;
                                                                                
                                                                                //added by arshad 23 Aug 2023
                                                                                if(hasAttachmentsToUpload){
                                                                                    setTimeout(function(){  window.location.replace(url); }, 5000);
                                                                                }else{
                                                                                    window.location.replace(url);
                                                                                }
                                                                            }
                                                                        }else if(component.get("v.fromProject")){
                                                                            var evt = $A.get("e.force:navigateToComponent");
                                                                            evt.setParams({
                                                                                componentDef : "c:Milestones",
                                                                                componentAttributes: {
                                                                                    "currentProj" : component.get("v.currentProj"),
                                                                                    "projectId" : component.get("v.ProjId"),
                                                                                    "newProj" : false
                                                                                }
                                                                            });
                                                                            evt.fire();
                                                                        }
                                                                            else{
                                                                                console.log('inhere navigateToRecord false');
                                                                                var selectedBillList=[];
                                                                                var result = response.getReturnValue(); 
                                                                                var bilobj = result['bill2'];
                                                                                var evt = $A.get("e.force:navigateToComponent");
                                                                                evt.setParams({
                                                                                    componentDef : "c:Accounts_Payable",
                                                                                    componentAttributes: {
                                                                                        "selectedTab" : 'Bills',
                                                                                        "setSearch" : bilobj.Name,
                                                                                    }
                                                                                });
                                                                                
                                                                                //added by arshad 23 Aug 2023
                                                                                if(hasAttachmentsToUpload){
                                                                                    setTimeout(function(){  evt.fire();  }, 5000);
                                                                                }else{
                                                                                    evt.fire(); 
                                                                                }
                                                                            }
                                                                        
                                                                        console.log('here 7');
                                                                        
                                                                        if(component.get("v.fromPortal")){
                                                                            //added by arshad 23 Aug 2023
                                                                            if(hasAttachmentsToUpload){
                                                                                setTimeout(function(){  location.reload();  }, 5000);
                                                                            }else{
                                                                                location.reload(); 
                                                                            }
                                                                        }
                                                                        
                                                                    }else{
                                                                        var errors = response.getError();
                                                                        console.log("server error in createBill : ", errors);
                                                                        try{
                                                                            if(errors != undefined && errors.length >0){
                                                                                let err = errors[0].message;
                                                                                helper.showToast('Error!','error', errors[0].message); 
                                                                            }
                                                                        }catch(e){ helper.showToast('Error!','error','Entries mismatch found!');  }
                                                                        
                                                                        component.set("v.showMmainSpin",false);
                                                                    }
                                                                    
                                                                }catch(e){
                                                                    console.log('error~>'+e);
                                                                    if(response.getState() === 'SUCCESS'){ 
                                                                        console.log('try error catch success so reloading if portalUser');
                                                                        if(component.get("v.fromPortal")){
                                                                            setTimeout(
                                                                                $A.getCallback(function() {
                                                                                    location.reload();
                                                                                }), 5000
                                                                            );
                                                                        }
                                                                    }else{
                                                                        var errors = response.getError();
                                                                        console.log("server error in createBill : ", errors);
                                                                        try{
                                                                            if(errors != undefined && errors.length >0){
                                                                                let err = errors[0].message;
                                                                                helper.showToast('Error!','error', errors[0].message); 
                                                                            }
                                                                        }catch(e){ helper.showToast('Error!','error','Entries mismatch found!');  }
                                                                        component.set("v.showMmainSpin",false);
                                                                    }
                                                                }
                                                                
                                                                //added by arshad 23 Aug 2023
                                                                if(hasAttachmentsToUpload){
                                                                    setTimeout(function(){   component.set("v.showMmainSpin",false);  }, 5000);
                                                                }else{
                                                                    component.set("v.showMmainSpin",false);
                                                                }
                                                                
                                                            });
                                                            $A.enqueueAction(saveAction);
                                                        }
                                            
                                        }
                                        else{
                                            var errorMessage = '';
                                            if(isErrorsAACOA){
                                                errorMessage = 'Please select the Accounting Account and Analytical Account.';
                                            }else if(isErrorsAA){
                                                errorMessage = 'Total Analytical Account amount of an item cannot be greater or lesser then line item total amount.';
                                            }
                                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',errorMessage);
                                        }
                                    }else{
                                        if(!showError) helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Please_add_a_Line_Item'));
                                        
                                    } 
                                }else{
                                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Review_All_Errors'));
                                    component.set("v.showMmainSpin",false);
                                }
                                }else{
                                    helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_Bill_Has_Already_Been_Created'));
                                    component.set("v.showMmainSpin",false);
                                    //return true;
                                }
                            }
                        }  
                        //component.set("v.showMmainSpin",false);
                    });
                    $A.enqueueAction(fetchpoliAction);
                }
            else{//edit part
                console.log('saveBill called');
                
                var billList = component.get("v.billItems");
                var Billobj = component.get("v.Bill");
                
                //alert('Bill=>'+JSON.stringify(component.get("v.Bill")));
                Billobj.ERP7__Vendor_Contact__r = null;
                Billobj.ERP7__Vendor_Address__r = null;
                Billobj.ERP7__Purchase_Order__r = null;
                Billobj.ERP7__Sales_Order__r = null;
                Billobj.ERP7__Posted__c = component.get('v.setBillPost');
                if(Billobj.ERP7__Total_Amount__c == undefined || Billobj.ERP7__Total_Amount__c == null || Billobj.ERP7__Total_Amount__c == '') Billobj.ERP7__Total_Amount__c = 0.00;
                
                var totalAmount=parseFloat(Billobj.ERP7__Amount__c);
                var advAmount=component.get('v.advPayment');
                if(component.get('v.setRT')=='Advance to vendor'){
                    var amount1=component.find('amount1').get('v.value');
                    if(parseFloat(amount1) <= 0 || amount1 ==''){
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_enter_a_valid_amount'));
                        component.set("v.showMmainSpin",false);
                        return;
                    }            
                    /*if(amount1 == (totalAmount-advAmount)){
                    helper.showToast('Error!','error','You are creating bill for full amount, Please create a purchase order bill');
                    return;
                }*/
                    if(amount1 > (totalAmount-advAmount)){
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Can_not_enter_more_than_todal_due_amount'));
                        component.set("v.showMmainSpin",false);
                        return;
                    }
                    Billobj.ERP7__Amount__c=amount1;
                }else{
                    Billobj.ERP7__Amount__c-=advAmount;
                }
                
                component.NOerrors =  true;
                helper.validation_Check(component,event);
                //component.set("v.showMmainSpin",false);
                var isErrorsAA = helper.AnalyticalAccountCheck(component, event, helper); 
                var isErrorsAACOA = helper.AnalyticalAccountCoaCheck(component, event, helper); 
                
                if(component.NOerrors){
                    var showError=false;
                    
                    if(billList.length>0){
                        for(var a = 0; a < billList.length; a++){//Moin added this on 13th september
                            //for(var a in billList ){
                            if(component.get("v.isMultiCurrency")) billList[a].CurrencyIsoCode = component.get("v.Bill.CurrencyIsoCode");
                            if(component.get("v.fromPortal") == false){ //change arshad
                                if(billList[a].ERP7__Chart_Of_Account__c=='' || billList[a].ERP7__Chart_Of_Account__c==null || billList[a].ERP7__Chart_Of_Account__c==undefined){
                                    showError=true;
                                    var po=component.get('v.Bill.ERP7__Purchase_Order__c');
                                    if(po!=null && po!='' && po!=undefined) helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_Select_the_inventory_account_for_all_line_items'));
                                    else helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Please_Select_the_expense_account_for_all_line_items'));
                                }
                            }
                        }
                    }
                    
                    if($A.util.isUndefinedOrNull(component.get("v.Bill.ERP7__Vendor_Bill_Number__c"))){
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_Enter_the_Vendor_Bill_Number'));
                        component.set("v.showMmainSpin",false);
                        return;
                    }
                    

                                            // added 14-11-2025 for deleting docs before save by Saqlain khan
                                          helper.SaveButtonForManageBillDoc(component);
                                         

                                          console.log('Save Bill button called line 620 after SaveButtonForManageBillDoc');
                    //Moin removed and added below code if(component.get("v.recordId") != null && component.get("v.recordId") ==  undefined &&  component.get("v.recordId") ==  ''){
                    if(component.get("v.recordId") != null && component.get("v.recordId") !=  undefined &&  component.get("v.recordId") !=  ''){
                        if(component.get("v.isAttRequired") && (component.get("v.uploadedFile") == null || component.get("v.uploadedFile").length == 0) && component.get('v.setRT')!='Advance to vendor'){
                            var fillList11=component.get("v.fillList");
                            if(component.get("v.isAttRequired") && (component.find("fileId").get("v.files")==null || fillList11.length == 0) && component.get('v.setRT')!='Advance to vendor'){
                                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Bill_Attachment_is_missing'));
                                component.set("v.showMmainSpin",false);
                                return;
                            }
                        }
                        //Moin commented this
                        /* 
                   else{
                       var fillList11=component.get("v.fillList");
                       if(component.get("v.isAttRequired") && (component.find("fileId").get("v.files")==null || fillList11.length == 0) && component.get('v.setRT')!='Advance to vendor'){
                           helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Bill_Attachment_is_missing'));
                           return;
                       }
                   }*/
                    }
                    else{
                        var fillList11=component.get("v.fillList");
                        if(component.get("v.isAttRequired") && (component.find("fileId").get("v.files")==null || fillList11.length == 0) && component.get('v.setRT')!='Advance to vendor'){
                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Bill_Attachment_is_missing'));
                            component.set("v.showMmainSpin",false);
                            return;
                        }
                    }
                    
                    
                    if(!component.get("v.SyncSalesforce") && !component.get("v.SyncGDrive") && component.get("v.isGDrive")){                
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Please Select Salesforce or Google Drive');
                        component.set("v.showMmainSpin",false);
                        return;
                    }
                    if(component.get("v.showAllocations")){
                        var accCheck =true;
                        accCheck = helper.AnalyticalAccountingAccountCheck(component, event, helper);
                        console.log('accCheck ************************************************************: '+accCheck);
                        if(!accCheck){
                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.AddAnalyticalAccount'));
                            component.set("v.showMmainSpin",false);
                            return;
                        }
                    }
                    if(billList.length > 0 && !(showError) ){
                        if(!isErrorsAA &&!isErrorsAACOA){
                            var shouldValidate = (component.get('v.setRT') === 'PO Bill');
                            if (shouldValidate) {
                                console.log('Inside PO Bill');
                                var billJson = JSON.stringify(component.get("v.billItems"));
                                var poliJson = '';//JSON.stringify(poliList);
                                console.log('billJson~>', billJson);
                                console.log('poliJson~>', poliJson);
                               // var poliList = component.get("v.poLineItems"); // whatever list you already hold for PO lines
                                
                                var validateAction2 = component.get("c.validateBillToleranceJson");
                                validateAction2.setParams({ billItemsJson: billJson, poliItemsJson: poliJson });
                                
                                validateAction2.setCallback(this, function(resp) {
                                    if (resp.getState()  === "SUCCESS") {
                                        console.log('resp.getState()', resp.getState());
                                        var err = resp.getReturnValue(); // String or null
                                        console.log('err', err);
                                        if (err !=null) {
                                            // ❌ Has tolerance issues → show and STOP. Do not clear Accounts.
                                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), 'error', err);
                                            component.set("v.showMmainSpin", false);
                                            return;
                                        }else{
                                            var dimensionList = [];
                                            try{
                                                
                                                //for(var x in billList){
                                                for(var x = 0; x < billList.length; x++){//Moin added this on 13th september
                                                    if(billList[x].Accounts != undefined && billList[x].Accounts != null){
                                                        if(billList[x].Accounts.length > 0){
                                                            for(var y in billList[x].Accounts){
                                                                if(billList[x].Accounts[y].ERP7__Sort_Order__c != undefined && billList[x].Accounts[y].ERP7__Sort_Order__c != null){
                                                                    console.log('before poLIst['+x+'].Accounts['+y+'].ERP7__Sort_Order__c ~>'+billList[x].Accounts[y].ERP7__Sort_Order__c);
                                                                    billList[x].Accounts[y].ERP7__Sort_Order__c = parseInt(parseInt(x)+1);
                                                                    console.log('after poLIst['+x+'].Accounts['+y+'].ERP7__Sort_Order__c ~>'+billList[x].Accounts[y].ERP7__Sort_Order__c);
                                                                }
                                                            }
                                                            dimensionList.push(billList[x].Accounts);
                                                        }
                                                    }
                                                }
                                                console.log('dimensionList : ',dimensionList);
                                                
                                                for(var x in billList){
                                                    if(billList[x].Accounts != undefined && billList[x].Accounts != null) billList[x].Accounts = [];
                                                }
                                            }catch(e){
                                                console.log('arshad err,',e);
                                            }
                                            
                                            component.set("v.showMmainSpin",true);
                                            //Moin commented and added this on 31st july 2023
                                            var saveAction = component.get("c.save_UpdatedBill");
                                            //var saveAction = component.get("c.save_Bill");
                                            console.log('JSON.stringify(Billobj)~>'+JSON.stringify(Billobj));
                                            console.log('JSON.stringify(billList)~>'+JSON.stringify(billList));
                                            
                                            let jsonBill  = JSON.stringify(Billobj);
                                            let jsonBillItems = JSON.stringify(billList);
                                            var RTName;
                                            if(component.get('v.setRT')=='PO Bill')RTName='PO_Bill';
                                            if(component.get('v.setRT')=='Expense Bill')RTName='Expense_Bill';
                                            if(component.get('v.setRT')=='Advance to vendor')RTName='Advance_to_vendor';
                                            
                                            console.log('saveBill v.clone~>'+component.get("v.clone"));
                                            
                                            saveAction.setParams({"Bill": jsonBill, "BillItems" :jsonBillItems,RTName:RTName,clone:component.get("v.clone")});
                                            saveAction.setCallback(this,function(response){
                                                try{
                                                    if(response.getState() === 'SUCCESS'){ 
                                                        console.log('success here 1 resp~>',JSON.stringify(response.getReturnValue()));
                                                        var result = response.getReturnValue();
                                                        //below error condition added here due to errors like Id is undefined
                                                        if(!$A.util.isUndefinedOrNull(result['error'])) {
                                                            console.log('here 5 ');
                                                            helper.showToast('Error!','error',result['error']);
                                                            component.set("v.showMmainSpin",false);
                                                            return ;
                                                        }
                                                        
                                                        var bilobj = result['bill']; 
                                                        component.set("v.BillId",bilobj.Id);
                                                        
                                                        if(component.get("v.clone")){
                                                            component.set("v.recordId", bilobj.Id);//Moin added this on 14th august 2023 if(component.get("v.clone")) 
                                                            console.log('inhere1 clone true saveBill');
                                                        }
                                                        
                                                        console.log('here 1.1 : ',bilobj.Id);
                                                        console.log('setRT : ',component.get('v.setRT'));
                                                        console.log('fillList11 :',fillList11);
                                                        
                                                        /*
                                    if(!$A.util.isUndefinedOrNull(result['error'])) {
                                        console.log('here 5 ');
                                        helper.showToast('Error!','error',result['error']);
                                        component.set("v.showMmainSpin",false);
                                        return ;
                                    }*/
                                        
                                        //added by arshad 23 Aug 2023
                                        var hasAttachmentsToUpload = false;
                                        
                                        if(component.get('v.setRT')=='PO Bill' || component.get('v.setRT')=='Expense Bill' || component.get('v.setRT')=='Advance to vendor'){
                                            if(component.find("fileId").get("v.files")!=null){
                                                console.log('fileId get v.files not null');
                                                if (component.find("fileId").get("v.files").length > 0 && component.find("fileId").get("v.files") != undefined && fillList11.length > 0 && fillList11 != undefined) {   
                                                    console.log('fileId get v.files length > 0');
                                                    hasAttachmentsToUpload = true;
                                                    var fileInput = component.get("v.FileList");
                                                    for(var i=0; i<fileInput.length; i++){
                                                        if(!component.get("v.clone")) helper.saveAtt(component,event,fileInput[i],bilobj.Id);
                                                        else helper.saveCloneAtt(component,event,fileInput[i],bilobj.Id);
                                                    } 
                                                }else console.log('not going fileId get v.files length 0');
                                            }else console.log('not going fileId get v.files null');
                                            
                                            console.log('Attach : ',component.get("v.Attach"));
                                            if(component.get("v.Attach")!=null){
                                                console.log('save_attachment2 here 3 ');
                                                var Billobj = component.get("v.BillId");
                                                var action=component.get("c.save_attachment2");
                                                action.setParams({"parentId": Billobj,"Pid":component.get("v.Bill.ERP7__Purchase_Order__c"), });
                                                action.setCallback(this,function(response){
                                                    if(response.getState() === 'SUCCESS'){
                                                        console.log('save_attachment2 here 4 success');
                                                    }else{
                                                        var errors = response.getError();
                                                        console.log("server error in save_attachment2 : ", JSON.stringify(errors));
                                                    }
                                                });
                                                $A.enqueueAction(action);
                                            }
                                            //return;
                                        }
                                        
                                        console.log('dimensionList.length : ',dimensionList.length);
                                        let itemsToDelete = component.get("v.itemsToDelete");
                                        if(itemsToDelete.length > 0){
                                            var action = component.get("c.deleteDimensionsNew");
                                            let itemsToDelete = component.get("v.itemsToDelete"); // This should be a list of record Ids (e.g., ['a0123...', 'a0456...'])
                                            action.setParams({ 'demIds': itemsToDelete });
                                            
                                            action.setCallback(this, function(response) {
                                                let state = response.getState();
                                                if (state === "SUCCESS") {
                                                    console.log('Deleted successfully');
                                                    // Optionally refresh the list or update UI
                                                } else {
                                                    console.error('Failed to delete: ', response.getError());
                                                }
                                            });
                                            $A.enqueueAction(action);
                                        }
                                        let LineitemsToDelete = component.get("v.LineitemsToDelete");
                                        if(LineitemsToDelete.length > 0){
                                            var action = component.get("c.deleteLineItems");
                                            
                                            action.setParams({ 'demIds': LineitemsToDelete });
                                            
                                            action.setCallback(this, function(response) {
                                                let state = response.getState();
                                                if (state === "SUCCESS") {
                                                    console.log('Deleted successfully');
                                                    // Optionally refresh the list or update UI
                                                } else {
                                                    console.error('Failed to delete: ', response.getError());
                                                }
                                            });
                                            $A.enqueueAction(action);
                                        }
                                        
                                        if(dimensionList.length > 0){
                                            try{
                                                var action2=component.get("c.createDimensionsList");
                                                action2.setParams({'dimelist':JSON.stringify(dimensionList), 'BillId':bilobj.Id});
                                                action2.setCallback(this,function(response){
                                                    if(response.getState() === "SUCCESS"){
                                                        console.log('createDimensionsList in success');
                                                        //component.set("v.isMultiCurrency",response.getReturnValue().isMulticurrency);
                                                        //component.set("v.currencyList",response.getReturnValue().currencyList);
                                                    }else{
                                                        var errors = response.getError();
                                                        console.log("server error in dimelist : ", JSON.stringify(errors));
                                                    } 
                                                });
                                                $A.enqueueAction(action2);
                                            }catch(e){
                                                console.log('arshad err 2,',e);
                                            }
                                        }
                                        
                                        // return;
                                        if(component.get("v.recordId") != null && component.get("v.recordId") !=  undefined && component.get("v.recordId") !=  '' && !component.get("v.clone")){
                                            console.log('inhere if going to record page');
                                            var RecId = component.get("v.recordId");
                                            var RecUrl = "/lightning/r/ERP7__Bill__c/" + RecId + "/view";
                                            helper.showToast($A.get('$Label.c.Success'),'success', result['bill'].Id+' '+ $A.get('$Label.c.Bill_Updated_Successfully'));
                                            
                                            //added by arshad 23 Aug 2023
                                            if(!component.get("v.fromAP")){
                                                if(hasAttachmentsToUpload){
                                                    setTimeout(function(){ window.open(RecUrl,'_parent'); }, 5000);
                                                }else{
                                                    window.open(RecUrl,'_parent');
                                                }
                                            }
                                        }
                                        else{
                                            console.log('inhere else bcoz maybe clone true');
                                            helper.showToast($A.get('$Label.c.Success'),'success', result['bill'].Id+' '+ $A.get('$Label.c.Bill_Created_Successfully'));  
                                        }
                                        
                                        if(component.get("v.navigateToRecord")){
                                            console.log('inhere navigateToRecord true ');
                                            var navEvt = $A.get("e.force:navigateToSObject");
                                            if(navEvt != undefined){
                                                navEvt.setParams({
                                                    "isredirect": true,
                                                    "recordId": result['bill'].Id,
                                                    "slideDevName": "detail"
                                                }); 
                                                
                                                //added by arshad 23 Aug 2023
                                                if(hasAttachmentsToUpload){
                                                    setTimeout(function(){  navEvt.fire(); }, 5000);
                                                }else{
                                                    navEvt.fire();
                                                }
                                            }
                                            else {
                                                console.log('inhere window.location.replace');
                                                var selectedBillList=[];
                                                selectedBillList.push(result['bill'].Id);
                                                var url = '/'+result['bill'].Id;
                                                
                                                //added by arshad 23 Aug 2023
                                                if(hasAttachmentsToUpload){
                                                    setTimeout(function(){  window.location.replace(url); }, 5000);
                                                }else{
                                                    window.location.replace(url);
                                                }
                                            }
                                        }
                                        else{
                                            console.log('inhere navigateToRecord false');
                                            var selectedBillList=[];
                                            var result = response.getReturnValue(); 
                                            var bilobj = result['bill2'];
                                            var evt = $A.get("e.force:navigateToComponent");
                                            evt.setParams({
                                                componentDef : "c:Accounts_Payable",
                                                componentAttributes: {
                                                    "selectedTab" : 'Bills',
                                                    "setSearch" : bilobj.Name,
                                                }
                                            });
                                            
                                            //added by arshad 23 Aug 2023
                                            if(hasAttachmentsToUpload){
                                                setTimeout(function(){  evt.fire();  }, 5000);
                                            }else{
                                                evt.fire(); 
                                            }
                                        }
                                        
                                        console.log('here 7');
                                        
                                        if(component.get("v.fromPortal")){
                                            //added by arshad 23 Aug 2023
                                            if(hasAttachmentsToUpload){
                                                setTimeout(function(){  location.reload();  }, 5000);
                                            }else{
                                                location.reload(); 
                                            }
                                        }
                                        
                                    }else{
                                        var errors = response.getError();
                                        console.log("server error in createBill : ", errors);
                                        try{
                                            if(errors != undefined && errors.length >0){
                                                let err = errors[0].message;
                                                helper.showToast('Error!','error', errors[0].message); 
                                            }
                                        }catch(e){ helper.showToast('Error!','error','Entries mismatch found!');  }
                                        
                                        component.set("v.showMmainSpin",false);
                                    }
                                    
                                }catch(e){
                                    console.log('error~>'+e);
                                    if(response.getState() === 'SUCCESS'){ 
                                        console.log('try error catch success so reloading if portalUser');
                                        if(component.get("v.fromPortal")){
                                            setTimeout(
                                                $A.getCallback(function() {
                                                    location.reload();
                                                }), 5000
                                            );
                                        }
                                    }else{
                                        var errors = response.getError();
                                        console.log("server error in createBill : ", errors);
                                        try{
                                            if(errors != undefined && errors.length >0){
                                                let err = errors[0].message;
                                                helper.showToast('Error!','error', errors[0].message); 
                                            }
                                        }catch(e){ helper.showToast('Error!','error','Entries mismatch found!');  }
                                        component.set("v.showMmainSpin",false);
                                    }
                                }
                                
                                //added by arshad 23 Aug 2023
                                if(hasAttachmentsToUpload){
                                    setTimeout(function(){   component.set("v.showMmainSpin",false);  }, 5000);
                                }else{
                                    component.set("v.showMmainSpin",false);
                                }
                                
                            });
                $A.enqueueAction(saveAction);
            }
        }
    });
    $A.enqueueAction(validateAction2);
    return; // stop the else-branch flow here until validation returns
}
                            else{
                                var dimensionList = [];
                                try{
                                    
                                    //for(var x in billList){
                                    for(var x = 0; x < billList.length; x++){//Moin added this on 13th september
                                        if(billList[x].Accounts != undefined && billList[x].Accounts != null){
                                            if(billList[x].Accounts.length > 0){
                                                for(var y in billList[x].Accounts){
                                                    if(billList[x].Accounts[y].ERP7__Sort_Order__c != undefined && billList[x].Accounts[y].ERP7__Sort_Order__c != null){
                                                        console.log('before poLIst['+x+'].Accounts['+y+'].ERP7__Sort_Order__c ~>'+billList[x].Accounts[y].ERP7__Sort_Order__c);
                                                        billList[x].Accounts[y].ERP7__Sort_Order__c = parseInt(parseInt(x)+1);
                                                        console.log('after poLIst['+x+'].Accounts['+y+'].ERP7__Sort_Order__c ~>'+billList[x].Accounts[y].ERP7__Sort_Order__c);
                                                    }
                                                }
                                                dimensionList.push(billList[x].Accounts);
                                            }
                                        }
                                    }
                                    console.log('dimensionList : ',dimensionList);
                                    
                                    for(var x in billList){
                                        if(billList[x].Accounts != undefined && billList[x].Accounts != null) billList[x].Accounts = [];
                                    }
                                }catch(e){
                                    console.log('arshad err,',e);
                                }
                                
                                component.set("v.showMmainSpin",true);
                                //Moin commented and added this on 31st july 2023
                                var saveAction = component.get("c.save_UpdatedBill");
                                //var saveAction = component.get("c.save_Bill");
                                console.log('JSON.stringify(Billobj)~>'+JSON.stringify(Billobj));
                                console.log('JSON.stringify(billList)~>'+JSON.stringify(billList));
                                
                                let jsonBill  = JSON.stringify(Billobj);
                                let jsonBillItems = JSON.stringify(billList);
                                var RTName;
                                if(component.get('v.setRT')=='PO Bill')RTName='PO_Bill';
                                if(component.get('v.setRT')=='Expense Bill')RTName='Expense_Bill';
                                if(component.get('v.setRT')=='Advance to vendor')RTName='Advance_to_vendor';
                                
                                console.log('saveBill v.clone~>'+component.get("v.clone"));
                                
                                saveAction.setParams({"Bill": jsonBill, "BillItems" :jsonBillItems,RTName:RTName,clone:component.get("v.clone")});
                                saveAction.setCallback(this,function(response){
                                    try{
                                        if(response.getState() === 'SUCCESS'){ 
                                            console.log('success here 1 resp~>',JSON.stringify(response.getReturnValue()));
                                            var result = response.getReturnValue();
                                            //below error condition added here due to errors like Id is undefined
                                            if(!$A.util.isUndefinedOrNull(result['error'])) {
                                                console.log('here 5 ');
                                                helper.showToast('Error!','error',result['error']);
                                                component.set("v.showMmainSpin",false);
                                                return ;
                                            }
                                            
                                            var bilobj = result['bill']; 
                                            component.set("v.BillId",bilobj.Id);
                                            
                                            if(component.get("v.clone")){
                                                component.set("v.recordId", bilobj.Id);//Moin added this on 14th august 2023 if(component.get("v.clone")) 
                                                console.log('inhere1 clone true saveBill');
                                            }
                                            
                                            console.log('here 1.1 : ',bilobj.Id);
                                            console.log('setRT : ',component.get('v.setRT'));
                                            console.log('fillList11 :',fillList11);
                                            
                                            /*
                                    if(!$A.util.isUndefinedOrNull(result['error'])) {
                                        console.log('here 5 ');
                                        helper.showToast('Error!','error',result['error']);
                                        component.set("v.showMmainSpin",false);
                                        return ;
                                    }*/
                                        
                                        //added by arshad 23 Aug 2023
                                        var hasAttachmentsToUpload = false;
                                        
                                        if(component.get('v.setRT')=='PO Bill' || component.get('v.setRT')=='Expense Bill' || component.get('v.setRT')=='Advance to vendor'){
                                            if(component.find("fileId").get("v.files")!=null){
                                                console.log('fileId get v.files not null');
                                                if (component.find("fileId").get("v.files").length > 0 && component.find("fileId").get("v.files") != undefined && fillList11.length > 0 && fillList11 != undefined) {   
                                                    console.log('fileId get v.files length > 0');
                                                    hasAttachmentsToUpload = true;
                                                    var fileInput = component.get("v.FileList");
                                                    for(var i=0; i<fileInput.length; i++){
                                                        if(!component.get("v.clone")) helper.saveAtt(component,event,fileInput[i],bilobj.Id);
                                                        else helper.saveCloneAtt(component,event,fileInput[i],bilobj.Id);
                                                    } 
                                                }else console.log('not going fileId get v.files length 0');
                                            }else console.log('not going fileId get v.files null');
                                            
                                            console.log('Attach : ',component.get("v.Attach"));
                                            if(component.get("v.Attach")!=null){
                                                console.log('save_attachment2 here 3 ');
                                                var Billobj = component.get("v.BillId");
                                                var action=component.get("c.save_attachment2");
                                                action.setParams({"parentId": Billobj,"Pid":component.get("v.Bill.ERP7__Purchase_Order__c"), });
                                                action.setCallback(this,function(response){
                                                    if(response.getState() === 'SUCCESS'){
                                                        console.log('save_attachment2 here 4 success');
                                                    }else{
                                                        var errors = response.getError();
                                                        console.log("server error in save_attachment2 : ", JSON.stringify(errors));
                                                    }
                                                });
                                                $A.enqueueAction(action);
                                            }
                                            //return;
                                        }
                                        
                                        console.log('dimensionList.length : ',dimensionList.length);
                                        let itemsToDelete = component.get("v.itemsToDelete");
                                        if(itemsToDelete.length > 0){
                                            var action = component.get("c.deleteDimensionsNew");
                                            let itemsToDelete = component.get("v.itemsToDelete"); // This should be a list of record Ids (e.g., ['a0123...', 'a0456...'])
                                            action.setParams({ 'demIds': itemsToDelete });
                                            
                                            action.setCallback(this, function(response) {
                                                let state = response.getState();
                                                if (state === "SUCCESS") {
                                                    console.log('Deleted successfully');
                                                    // Optionally refresh the list or update UI
                                                } else {
                                                    console.error('Failed to delete: ', response.getError());
                                                }
                                            });
                                            $A.enqueueAction(action);
                                        }
                                        let LineitemsToDelete = component.get("v.LineitemsToDelete");
                                        if(LineitemsToDelete.length > 0){
                                            var action = component.get("c.deleteLineItems");
                                            
                                            action.setParams({ 'demIds': LineitemsToDelete });
                                            
                                            action.setCallback(this, function(response) {
                                                let state = response.getState();
                                                if (state === "SUCCESS") {
                                                    console.log('Deleted successfully');
                                                    // Optionally refresh the list or update UI
                                                } else {
                                                    console.error('Failed to delete: ', response.getError());
                                                }
                                            });
                                            $A.enqueueAction(action);
                                        }
                                        
                                        if(dimensionList.length > 0){
                                            try{
                                                var action2=component.get("c.createDimensionsList");
                                                action2.setParams({'dimelist':JSON.stringify(dimensionList), 'BillId':bilobj.Id});
                                                action2.setCallback(this,function(response){
                                                    if(response.getState() === "SUCCESS"){
                                                        console.log('createDimensionsList in success');
                                                        //component.set("v.isMultiCurrency",response.getReturnValue().isMulticurrency);
                                                        //component.set("v.currencyList",response.getReturnValue().currencyList);
                                                    }else{
                                                        var errors = response.getError();
                                                        console.log("server error in dimelist : ", JSON.stringify(errors));
                                                    } 
                                                });
                                                $A.enqueueAction(action2);
                                            }catch(e){
                                                console.log('arshad err 2,',e);
                                            }
                                        }
                                        
                                        // return;
                                        if(component.get("v.recordId") != null && component.get("v.recordId") !=  undefined && component.get("v.recordId") !=  '' && !component.get("v.clone")){
                                            console.log('inhere if going to record page');
                                            var RecId = component.get("v.recordId");
                                            var RecUrl = "/lightning/r/ERP7__Bill__c/" + RecId + "/view";
                                            helper.showToast($A.get('$Label.c.Success'),'success', result['bill'].Id+' '+ $A.get('$Label.c.Bill_Updated_Successfully'));
                                            
                                            //added by arshad 23 Aug 2023
                                            if(!component.get("v.fromAP")){
                                                if(hasAttachmentsToUpload){
                                                    setTimeout(function(){ window.open(RecUrl,'_parent'); }, 5000);
                                                }else{
                                                    window.open(RecUrl,'_parent');
                                                }
                                            }
                                        }
                                        else{
                                            console.log('inhere else bcoz maybe clone true');
                                            helper.showToast($A.get('$Label.c.Success'),'success', result['bill'].Id+' '+ $A.get('$Label.c.Bill_Created_Successfully'));  
                                        }
                                        
                                        if(component.get("v.navigateToRecord")){
                                            console.log('inhere navigateToRecord true ');
                                            var navEvt = $A.get("e.force:navigateToSObject");
                                            if(navEvt != undefined){
                                                navEvt.setParams({
                                                    "isredirect": true,
                                                    "recordId": result['bill'].Id,
                                                    "slideDevName": "detail"
                                                }); 
                                                
                                                //added by arshad 23 Aug 2023
                                                if(hasAttachmentsToUpload){
                                                    setTimeout(function(){  navEvt.fire(); }, 5000);
                                                }else{
                                                    navEvt.fire();
                                                }
                                            }
                                            else {
                                                console.log('inhere window.location.replace');
                                                var selectedBillList=[];
                                                selectedBillList.push(result['bill'].Id);
                                                var url = '/'+result['bill'].Id;
                                                
                                                //added by arshad 23 Aug 2023
                                                if(hasAttachmentsToUpload){
                                                    setTimeout(function(){  window.location.replace(url); }, 5000);
                                                }else{
                                                    window.location.replace(url);
                                                }
                                            }
                                        }
                                        else{
                                            console.log('inhere navigateToRecord false');
                                            var selectedBillList=[];
                                            var result = response.getReturnValue(); 
                                            var bilobj = result['bill2'];
                                            var evt = $A.get("e.force:navigateToComponent");
                                            evt.setParams({
                                                componentDef : "c:Accounts_Payable",
                                                componentAttributes: {
                                                    "selectedTab" : 'Bills',
                                                    "setSearch" : bilobj.Name,
                                                }
                                            });
                                            
                                            //added by arshad 23 Aug 2023
                                            if(hasAttachmentsToUpload){
                                                setTimeout(function(){  evt.fire();  }, 5000);
                                            }else{
                                                evt.fire(); 
                                            }
                                        }
                                        
                                        console.log('here 7');
                                        
                                        if(component.get("v.fromPortal")){
                                            //added by arshad 23 Aug 2023
                                            if(hasAttachmentsToUpload){
                                                setTimeout(function(){  location.reload();  }, 5000);
                                            }else{
                                                location.reload(); 
                                            }
                                        }
                                        
                                    }else{
                                        var errors = response.getError();
                                        console.log("server error in createBill : ", errors);
                                        try{
                                            if(errors != undefined && errors.length >0){
                                                let err = errors[0].message;
                                                helper.showToast('Error!','error', errors[0].message); 
                                            }
                                        }catch(e){ helper.showToast('Error!','error','Entries mismatch found!');  }
                                        
                                        component.set("v.showMmainSpin",false);
                                    }
                                    
                                }catch(e){
                                    console.log('error~>'+e);
                                    if(response.getState() === 'SUCCESS'){ 
                                        console.log('try error catch success so reloading if portalUser');
                                        if(component.get("v.fromPortal")){
                                            setTimeout(
                                                $A.getCallback(function() {
                                                    location.reload();
                                                }), 5000
                                            );
                                        }
                                    }else{
                                        var errors = response.getError();
                                        console.log("server error in createBill : ", errors);
                                        try{
                                            if(errors != undefined && errors.length >0){
                                                let err = errors[0].message;
                                                helper.showToast('Error!','error', errors[0].message); 
                                            }
                                        }catch(e){ helper.showToast('Error!','error','Entries mismatch found!');  }
                                        component.set("v.showMmainSpin",false);
                                    }
                                }
                                
                                //added by arshad 23 Aug 2023
                                if(hasAttachmentsToUpload){
                                    setTimeout(function(){   component.set("v.showMmainSpin",false);  }, 5000);
                                }else{
                                    component.set("v.showMmainSpin",false);
                                }
                                
                            });
                            $A.enqueueAction(saveAction);
                        }
                            //else of tolernace
                        }
                        //
                        else{
                        var errorMessage = '';
                        if(isErrorsAACOA){
                            errorMessage = 'Please select the Accounting Account and Analytical Account.';
                        }else if(isErrorsAA){
                            errorMessage = 'Total Analytical Account amount of an item cannot be greater or lesser then line item total amount.';
                        }
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',errorMessage);
                        component.set("v.showMmainSpin",false);
                    }
                }else{
                    if(!showError) helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Please_add_a_Line_Item'));
                    component.set("v.showMmainSpin",false);
                    
                } 
                }else{
                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Review_All_Errors'));
                    component.set("v.showMmainSpin",false);
                }
            }
        }
            
            catch(e){
                console.log('Error On Saving Bills ',e);
            }
        }
     },
    
    goBack : function(component, event, helper) {
        //location.reload();
        if(component.get("v.recordId") != null && component.get("v.recordId") !=  undefined && component.get("v.recordId") !=  '' && !component.get("v.fromAP")){
            var RecId = component.get("v.recordId");
            var RecUrl = "/lightning/r/ERP7__Bill__c/" + RecId + "/view";
            window.open(RecUrl,'_parent');
        }
        else if(component.get("v.fromAP")){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Accounts_Payable",
                componentAttributes: {
                    "aura:id": "AccountsPayable",
                    "selectedTab":"Bills"
                }
            });
            evt.fire();
        }else if(component.get("v.fromProject")){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Milestones",
                componentAttributes: {
                    "currentProj" : component.get("v.currentProj"),
                    "projectId" : component.get("v.ProjId"),
                    "newProj" : false
                }
            });
            evt.fire();
        }else if(component.get("v.supplier")){
                $A.createComponent("c:SupplierPortalBills",{
                },function(newCmp, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = component.find("body");
                        body.set("v.body", newCmp);
                    }
                });
            }else if(component.get("v.recordPage")){
                history.back(); 
            }else{
                $A.createComponent("c:SupplierPortalPO",{
                },function(newCmp, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = component.find("body");
                        body.set("v.body", newCmp);
                    }
                });
            }
        //history.back();  
    },
    
    validateField : function(component, event, helper){
        var billName = component.find("billName");
        if(!$A.util.isUndefined(billName)) 
            helper.checkValidationField(component,billName);
    },
    
    addNew : function(component, event, helper) {
        try{
            var billList = component.get("v.billItems");
            billList.push({sObjectType :'ERP7__Bill_Line_Item__c',Accounts : [], Category:'', AccAccount:''});
            console.log('billList'+JSON.stringify(billList));
            component.set("v.billItems",billList);
        }catch(e){
            console.log('addNew err',e);
        }
    },
    
    Newone: function (component, event, helper) {
    try {
        var billList = component.get("v.billItems") || []; // Get the existing billItems list
        console.log('billList without changes:', JSON.stringify(billList));
        // No rows are added or modified here
        component.set("v.billItems", billList); // Just update the list without any changes
    } catch (e) {
        console.error('Newone error:', e);
    }
},

    
    delete_Item : function(component, event, helper) {
        var billList = component.get("v.billItems");
        billList.splice(component.get("v.Index2del"),1);
        component.set("v.billItems",billList);
    },
    
    deleteLineItem : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        try{
            var billList = component.get("v.billItems");
            let index = event.getParam("Index");
            let itemToDelete = billList[index];
            let itemsToDelete = component.get("v.LineitemsToDelete") || [];
            itemsToDelete.push(itemToDelete);
            
            component.set("v.LineitemsToDelete", itemsToDelete);
            billList.splice(event.getParam("Index"),1);
            component.set("v.billItems",billList);
            setTimeout(function() {
                component.set("v.showMmainSpin", false);
            }, 2000);
            $A.enqueueAction(component.get("c.updateTotalDiscount"));
            $A.enqueueAction(component.get("c.updateTotalPrice"));
            $A.enqueueAction(component.get("c.updateTotalTax"));
        }catch(e){
            console.log('deleteLineItem err',e);
            setTimeout(function() {
                // Hide the spinner after 2 seconds
                component.set("v.showMmainSpin", false);
            }, 2000);
        }
    },
    deletePoliAcc : function(component, event, helper) {
        let indexvalue = event.getParam("value");
        let itemsToDelete = component.get("v.itemsToDelete");
        itemsToDelete.push(indexvalue);
        console.log('value: ',indexvalue);
        component.set("v.itemsToDelete", itemsToDelete);
        console.log('itemsToDelete: ',itemsToDelete);
    },
    
    
     fetchPolis: function(component, event, helper) {
            // For OCR part.
            var fetchpoliAction = component.get("v.ShowBillLineItems");

            if (fetchpoliAction === false) {
                console.log('fetchPolis called from cmp', fetchpoliAction);
                 $A.enqueueAction(component.get("c.fetchPoli"));
            } else {
                component.set("v.ShowBillLineItems", false);
               if(component.get('v.recordId') == null || component.get('v.recordId') == '' || component.get('v.recordId') == undefined){
            try{
                var fetchpoliAction = component.get("c.fetch_Polis");
                fetchpoliAction.setParams({"Id":component.get("v.Bill.ERP7__Purchase_Order__c")});
                fetchpoliAction.setCallback(this,function(response){
                    if(response.getState() === 'SUCCESS'){
                        var resultList = response.getReturnValue();
                        if(resultList.length > 0){
                            console.log('in here fetchpoliAction~>'+JSON.stringify(resultList));
                            try{
                                var po = JSON.parse(resultList[0]);
                                component.set("v.Bill.ERP7__Vendor__c", po.ERP7__Vendor__c);
                                component.set("v.Bill.ERP7__Sales_Order__c", po.ERP7__Sales_Order__c);
                                component.set("v.Bill.ERP7__Vendor_Contact__c", po.ERP7__Vendor_Contact__c);
                                component.set("v.Bill.ERP7__Vendor_Address__c", po.ERP7__Vendor_Address__c);
                                component.set("v.Bill.ERP7__Project__c", po.ERP7__Project__c);
                                component.set("v.Bill.ERP7__Department__c", po.ERP7__Organisation_Business_Unit__c);
                                var descrip = '';
                                if(po.ERP7__Description__c!=null && po.ERP7__Description__c !=undefined && po.ERP7__Description__c!=''){
                                    descrip = po.ERP7__Description__c;
                                    descrip = descrip.replace(/<[^>]*>/g, '');
                                }
                                component.set("v.Bill.ERP7__Description__c", descrip);
                                //component.set("v.Bill.ERP7__Description__c", po.ERP7__Description__c);
                                //alert('PO Org : ' +po.ERP7__Organisation__c);
                                component.set("v.Bill.ERP7__Organisation__c", po.ERP7__Organisation__c);
                                var poliList = JSON.parse(resultList[1]);
                                var billingQty = JSON.parse(resultList[2]);
                                //alert('1==>'+JSON.stringify(poliList));
                                if(!$A.util.isEmpty(poliList)){
                                    var billList = [];//component.get("v.billItems");
                                    for(var x in poliList){
                                        for(var y in billingQty){
                                            if(x == y){
                                                //Changes made by Arshad tp populate tax rate same as it is from poli, to handle even if partial bills qty created - 29-June-2023
                                                if(poliList[x].ERP7__Product__c == null || poliList[x].ERP7__Product__c == undefined){
                                                    var obj = {ERP7__Chart_Of_Account__c:null,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,ERP7__Discount__c:0.00,
                                                               ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c,ERP7__Vendor_Part_Number__c : poliList[x].ERP7__Vendor_product_Name__c};
                                                    billList.push(obj);
                                                }else if(poliList[x].ERP7__Product__r.ERP7__Track_Inventory__c && !poliList[x].ERP7__Product__r.ERP7__Is_Asset__c){//Moin added this 29th november 2023 && !poliList[x].ERP7__Product__r.ERP7__Is_Asset__c
                                                    console.log('poliList[x]~>',JSON.stringify(poliList[x]));
                                                    var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,
                                                               ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c,ERP7__Vendor_Part_Number__c : poliList[x].ERP7__Vendor_product_Name__c};//,ERP7__Product__r : {ProductCode : poliList[x].ERP7__Product__r.ProductCode}
                                                    billList.push(obj);
                                                }else if(poliList[x].ERP7__Product__r.ERP7__Is_Asset__c){
                                                    var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Asset_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,
                                                               ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c,ERP7__Vendor_Part_Number__c : poliList[x].ERP7__Vendor_product_Name__c};//,ERP7__Product__r : {ProductCode : poliList[x].ERP7__Product__r.ProductCode}
                                                    billList.push(obj);
                                                }else{
                                                    console.log('in here expense po');
                                                    var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,
                                                               ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c,ERP7__Vendor_Part_Number__c : poliList[x].ERP7__Vendor_product_Name__c};//,ERP7__Product__r : {ProductCode : poliList[x].ERP7__Product__r.ProductCode}
                                                    billList.push(obj);
                                                }
                                            }
                                        }
                                    }     
                                    console.log('billList~>',JSON.stringify(billList));
                                    
                                   
                                 /*   // Collect product names from billList
                                        var productNames = billList
                                            .map(function(item){ return item.Name; })
                                            .filter(function(name){ return name != null && name != undefined && name != ''; });
                                        
                                        console.log('Collected productNames => ', JSON.stringify(productNames));
                                        
                                        // 🔹 Get products with Id but no description
                                        var missingDescProducts = component.get("v.missingDescProducts") || [];
                                        
                                        // 🔹 Filter billList: keep only matching items
                                        var filteredBillList = [];
                                        if(missingDescProducts.length > 0){
                                            filteredBillList = billList.filter(function(item){
                                                return missingDescProducts.some(function(prod){
                                                    return prod.idValue === item.ERP7__Product__c || prod.keyName === item.Name;
                                                });
                                            });
                                        }
                                        
                                        console.log("✅ Filtered Bill List => ", JSON.stringify(filteredBillList));
                                        
                                        // 🔹 If no matches, clear everything
                                        component.set("v.billItems", filteredBillList);  */

                                    
                                 // Collect product names from billList
var productNames = billList
    .map(function(item) { return item.Name; })
    .filter(function(name) { return name != null && name != undefined && name != ''; });

console.log('Collected productNames => ', JSON.stringify(productNames));

// 🔹 Get products with Id but no description
var missingDescProducts = component.get("v.missingDescProducts") || [];

// 🔹 Build final list: only matched products, update qty & discount
var filteredBillList = [];
var extraQtyProducts = []; // store products with extra qty

if (missingDescProducts.length > 0) {
    filteredBillList = billList
        .map(function(item) {
            var match = missingDescProducts.find(function(prod) {
                return prod.idValue === item.ERP7__Product__c || prod.keyName === item.Name;
            });

            if (match) {
                // deep copy to keep other fields intact
                var newItem = JSON.parse(JSON.stringify(item));

                // ✅ always update qty from extracted invoice data
                newItem.ERP7__Quantity__c = match.quantity;

                // ✅ If invoice qty > PO qty → capture delta
                if (match.quantity > item.ERP7__Quantity__c) {
                    var deltaQty = match.quantity - item.ERP7__Quantity__c;

                    newItem.ERP7__Description__c =
                        'The quantity of this item has been updated from ' +
                        item.ERP7__Quantity__c + ' to ' + match.quantity +
                        ' as per the bill uploaded, which is greater than the Purchase Order.';

                    extraQtyProducts.push({
                        productName: match.keyName,
                        extraQty: deltaQty,
                        unitPrice: item.ERP7__Amount__c,
                    });
                }

                return newItem;
            }
            return null; // skip non-matching
        })
        .filter(function(item) { return item !== null; });
}

console.log("✅ Final Bill List => ", JSON.stringify(filteredBillList));
console.log("➕ Extra Qty Products => ", JSON.stringify(extraQtyProducts));

// Save to component for UI use
component.set("v.extraQtyProducts", extraQtyProducts);

var notInPOProducts = component.get("v.productKeyIdList") || [];

// ✅ Build single description text with highlighted names
if (notInPOProducts.length > 0) {
    // this is for creating po for these products
    component.set("v.productKeyIdListTrue", true);

    console.log("Products not in PO => ", JSON.stringify(notInPOProducts));

    // Get extracted items (with qty & unitPrice)
    var extractedItems = component.get("v.extractedItems") || [];

    // Build description with productName, qty & unitPrice
    var descMessages = notInPOProducts.map(function(prod) {
        var matchRow = extractedItems.find(function(row) {
            return row.productName === prod.keyName;
        });

        var qty = matchRow ? matchRow.quantity : 0;
        var price = matchRow ? matchRow.unitPrice : 0;

        return "'" + prod.keyName + "' with (Qty: " + qty + " and Unit Price: " + price + ")";
    });

    var descMessage = "The Product " + descMessages.join(", ") + " are not a part of this Purchase Order.";
    component.set("v.Bill.ERP7__Description__c", descMessage);

    console.log("📝 Bill Description set => ", component.get("v.Bill.ERP7__Description__c"));
}


                                        // 🔹 Set only matched products
                                        component.set("v.billItems", filteredBillList);

                                    console.log('arshad before getPOLIDimeListhelper for PO fromhere1');
                                    
                                    if(component.get("v.Bill.ERP7__Purchase_Order__c") != undefined && component.get("v.Bill.ERP7__Purchase_Order__c") != null && component.get("v.Bill.ERP7__Purchase_Order__c") != '' && component.get("v.billItems") != null && component.get("v.billItems") != undefined){
                                        if(component.get("v.billItems.length") > 0){
                                            helper.getPOLIDimeListhelper(component,event,helper);
                                        }
                                    }
                                    //var billPo=component.get("v.Bill.ERP7__Purchase_Order__c");
                                    if(component.get("v.Bill.ERP7__Purchase_Order__c") != undefined && component.get("v.Bill.ERP7__Purchase_Order__c") != null && component.get("v.Bill.ERP7__Purchase_Order__c") != ''){
                                        if(component.get("v.isMultiCurrency")) { 
                                            helper.fetchPOCurrncy(component,event,helper); 
                                        }
                                    }
                                    //component.set('v.setRT','PO Bill');
                                    component.set("v.Bill.ERP7__Discount_Amount__c",0);
                                    helper.calculateAdvBill(component,event);
                                    //
                                }else{
                                    helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_Bill_Has_Already_Been_Created'));
                                    setTimeout(
                                        $A.getCallback(function() {
                                            $A.enqueueAction(component.get("c.cancelclick"));
                                        }), 3000
                                    );
                                    
                                }
                            }catch(e){
                                console.log('arshad err1',e);
                            }
                        }
                    }  
                });
                $A.enqueueAction(fetchpoliAction);
                var action2=component.get("c.uploadFile2");
                action2.setParams({
                    "pid" : component.get("v.Bill.ERP7__Purchase_Order__c")
                });
                action2.setCallback(this, function(response){
                    var state = response.getState();
                    if( state === "SUCCESS" ){
                        if(!component.get("v.clone")){
                            component.set("v.fileName",response.getReturnValue().Name);
                            component.set("v.Attach",response.getReturnValue());
                        }
                        
                    }
                });
                $A.enqueueAction(action2);
            }catch(e){
                console.log('arshad err2',e);
            }
        }
            }
        },
    
    
    fetchPoli : function(component, event, helper) {
        console.log('fetchPoli called');
        if(component.get('v.recordId') == null || component.get('v.recordId') == '' || component.get('v.recordId') == undefined){
            try{
                var fetchpoliAction = component.get("c.fetch_Polis");
                fetchpoliAction.setParams({"Id":component.get("v.Bill.ERP7__Purchase_Order__c")});
                fetchpoliAction.setCallback(this,function(response){
                    if(response.getState() === 'SUCCESS'){
                        var resultList = response.getReturnValue();
                        if(resultList.length > 0){
                            console.log('in here fetchpoliAction~>'+JSON.stringify(resultList));
                            try{
                                var po = JSON.parse(resultList[0]);
                                component.set("v.Bill.ERP7__Vendor__c", po.ERP7__Vendor__c);
                                component.set("v.Bill.ERP7__Sales_Order__c", po.ERP7__Sales_Order__c);
                                component.set("v.Bill.ERP7__Vendor_Contact__c", po.ERP7__Vendor_Contact__c);
                                component.set("v.Bill.ERP7__Vendor_Address__c", po.ERP7__Vendor_Address__c);
                                component.set("v.Bill.ERP7__Project__c", po.ERP7__Project__c);
                                component.set("v.Bill.ERP7__Department__c", po.ERP7__Organisation_Business_Unit__c);
                                var descrip = '';
                                if(po.ERP7__Description__c!=null && po.ERP7__Description__c !=undefined && po.ERP7__Description__c!=''){
                                    descrip = po.ERP7__Description__c;
                                    descrip = descrip.replace(/<[^>]*>/g, '');
                                }
                                component.set("v.Bill.ERP7__Description__c", descrip);
                                //component.set("v.Bill.ERP7__Description__c", po.ERP7__Description__c);
                                //alert('PO Org : ' +po.ERP7__Organisation__c);
                                component.set("v.Bill.ERP7__Organisation__c", po.ERP7__Organisation__c);
                                var poliList = JSON.parse(resultList[1]);
                                var billingQty = JSON.parse(resultList[2]);
                                //alert('1==>'+JSON.stringify(poliList));
                                if(!$A.util.isEmpty(poliList)){
                                    var billList = [];//component.get("v.billItems");
                                    for(var x in poliList){
                                        for(var y in billingQty){
                                            if(x == y){
                                                //Changes made by Arshad tp populate tax rate same as it is from poli, to handle even if partial bills qty created - 29-June-2023
                                                if(poliList[x].ERP7__Product__c == null || poliList[x].ERP7__Product__c == undefined){
                                                    var obj = {ERP7__Chart_Of_Account__c:null,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,ERP7__Discount__c:0.00,
                                                               ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c,ERP7__Vendor_Part_Number__c : poliList[x].ERP7__Vendor_product_Name__c};
                                                    billList.push(obj);
                                                }else if(poliList[x].ERP7__Product__r.ERP7__Track_Inventory__c && !poliList[x].ERP7__Product__r.ERP7__Is_Asset__c){//Moin added this 29th november 2023 && !poliList[x].ERP7__Product__r.ERP7__Is_Asset__c
                                                    console.log('poliList[x]~>',JSON.stringify(poliList[x]));
                                                    var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,
                                                               ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c,ERP7__Vendor_Part_Number__c : poliList[x].ERP7__Vendor_product_Name__c};//,ERP7__Product__r : {ProductCode : poliList[x].ERP7__Product__r.ProductCode}
                                                    billList.push(obj);
                                                }else if(poliList[x].ERP7__Product__r.ERP7__Is_Asset__c){
                                                    var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Asset_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,
                                                               ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c,ERP7__Vendor_Part_Number__c : poliList[x].ERP7__Vendor_product_Name__c};//,ERP7__Product__r : {ProductCode : poliList[x].ERP7__Product__r.ProductCode}
                                                    billList.push(obj);
                                                }else{
                                                    console.log('in here expense po');
                                                    var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,
                                                               ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c,ERP7__Vendor_Part_Number__c : poliList[x].ERP7__Vendor_product_Name__c};//,ERP7__Product__r : {ProductCode : poliList[x].ERP7__Product__r.ProductCode}
                                                    billList.push(obj);
                                                }
                                            }
                                        }
                                    }     
                                    console.log('billList~>',JSON.stringify(billList));
                                    
                                   
                                    
                                    component.set("v.billItems",billList);
                                    console.log('arshad before getPOLIDimeListhelper for PO fromhere1');
                                    
                                    if(component.get("v.Bill.ERP7__Purchase_Order__c") != undefined && component.get("v.Bill.ERP7__Purchase_Order__c") != null && component.get("v.Bill.ERP7__Purchase_Order__c") != '' && component.get("v.billItems") != null && component.get("v.billItems") != undefined){
                                        if(component.get("v.billItems.length") > 0){
                                            helper.getPOLIDimeListhelper(component,event,helper);
                                        }
                                    }
                                    //var billPo=component.get("v.Bill.ERP7__Purchase_Order__c");
                                    if(component.get("v.Bill.ERP7__Purchase_Order__c") != undefined && component.get("v.Bill.ERP7__Purchase_Order__c") != null && component.get("v.Bill.ERP7__Purchase_Order__c") != ''){
                                        if(component.get("v.isMultiCurrency")) { 
                                            helper.fetchPOCurrncy(component,event,helper); 
                                        }
                                    }
                                    //component.set('v.setRT','PO Bill');
                                    component.set("v.Bill.ERP7__Discount_Amount__c",0);
                                    helper.calculateAdvBill(component,event);
                                    //
                                }else{
                                    helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_Bill_Has_Already_Been_Created'));
                                    setTimeout(
                                        $A.getCallback(function() {
                                            $A.enqueueAction(component.get("c.cancelclick"));
                                        }), 3000
                                    );
                                    
                                }
                            }catch(e){
                                console.log('arshad err1',e);
                            }
                        }
                    }  
                });
                $A.enqueueAction(fetchpoliAction);
                var action2=component.get("c.uploadFile2");
                action2.setParams({
                    "pid" : component.get("v.Bill.ERP7__Purchase_Order__c")
                });
                action2.setCallback(this, function(response){
                    var state = response.getState();
                    if( state === "SUCCESS" ){
                        if(!component.get("v.clone")){
                            component.set("v.fileName",response.getReturnValue().Name);
                            component.set("v.Attach",response.getReturnValue());
                        }
                        
                    }
                });
                $A.enqueueAction(action2);
            }catch(e){
                console.log('arshad err2',e);
            }
        }
    },




    //ocr
    fetchMultiPolis : function(component, event, helper) {

        console.log('fetchMultiPoli called');
        try{
            var fetchpoliAction = component.get("c.fetch_Polis_Multi");
            fetchpoliAction.setParams({"Ids":component.get("v.POIdsList")});
            fetchpoliAction.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    var resultList = response.getReturnValue();
                    if(resultList.length > 0){
                        console.log('in here fetchpoliAction~>'+JSON.stringify(resultList));
                        try{
                            var po = JSON.parse(resultList[0]);
                            component.set("v.Bill.ERP7__Vendor__c", po.ERP7__Vendor__c);
                            //component.set("v.Bill.ERP7__Sales_Order__c", po.ERP7__Sales_Order__c);
                            component.set("v.Bill.ERP7__Vendor_Contact__c", po.ERP7__Vendor_Contact__c);
                            component.set("v.Bill.ERP7__Vendor_Address__c", po.ERP7__Vendor_Address__c);
                            //component.set("v.Bill.ERP7__Description__c", po.ERP7__Description__c);
                            //alert('PO Org : ' +po.ERP7__Organisation__c);
                            component.set("v.Bill.ERP7__Organisation__c", po.ERP7__Organisation__c);
                            var poliList = JSON.parse(resultList[1]);
                            var billingQty = JSON.parse(resultList[2]);
                            var PoList = JSON.parse(resultList[3]);
                            component.set("v.PoList", PoList);
                            //alert('1==>'+JSON.stringify(poliList));
                            if(!$A.util.isEmpty(poliList)){
                                var billList = [];//component.get("v.billItems");
                                for(var x in poliList){
                                    for(var y in billingQty){
                                        if(x == y){
                                            //Changes made by Arshad tp populate tax rate same as it is from poli, to handle even if partial bills qty created - 29-June-2023
                                            if(poliList[x].ERP7__Product__c == null || poliList[x].ERP7__Product__c == undefined){
                                                var obj = {ERP7__Chart_Of_Account__c:null,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,ERP7__Discount__c:0.00,
                                                           ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c};
                                                billList.push(obj);
                                            }else if(poliList[x].ERP7__Product__r.ERP7__Track_Inventory__c){
                                                console.log('poliList[x]~>'+JSON.stringify(poliList[x]));
                                                var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,
                                                           ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c};
                                                billList.push(obj);
                                            }else if(poliList[x].ERP7__Product__r.ERP7__Is_Asset__c){
                                                var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Asset_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,
                                                           ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c};
                                                billList.push(obj);
                                            }else{
                                                console.log('in here expense po');
                                                var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,
                                                           ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c};
                                                billList.push(obj);
                                            }
                                        }
                                    }
                                }     




console.log('The billList before all the funtionality ----------------->',JSON.stringify(billList));


// 🔹 Step 1: Merge duplicates in billList (by Product Id if available, else by Name)
var mergedBillMap = {};
billList.forEach(function(item) {
    var key = item.ERP7__Product__c || item.Name; // Prefer Product Id, fallback to Name
    if (!mergedBillMap[key]) {
        mergedBillMap[key] = JSON.parse(JSON.stringify(item));
    } else {
        // Only add quantities
        mergedBillMap[key].ERP7__Quantity__c += item.ERP7__Quantity__c;
    }
});




// Replace billList with deduped values
billList = Object.values(mergedBillMap);

console.log("🧩 Deduped billList  after vthe merge => ", JSON.stringify(billList));

// 🔹 Step 2: Collect product names (after dedupe)
var productNames = billList
    .map(function(item) { return item.Name; })
    .filter(function(name) { return name != null && name != undefined && name != ''; });

console.log('Collected productNames => ', JSON.stringify(productNames));
console.log('Collected productNames => ', JSON.stringify(productNames));

// 🔹 Get products with Id but no description (includes PO Id match OR Name match)
var missingDescProducts = component.get("v.missingDescProducts") || [];

// 🔹 Merge duplicates in missingDescProducts (by Id if available, else by Name)
var mergedMissingMap = {};
missingDescProducts.forEach(function(prod) {
    var key = prod.idValue || prod.keyName; // Prefer Id, fallback to Name
    if (!mergedMissingMap[key]) {
        mergedMissingMap[key] = JSON.parse(JSON.stringify(prod));
    } else {
        // Add quantities
        mergedMissingMap[key].quantity += prod.quantity;

        
    }
});
missingDescProducts = Object.values(mergedMissingMap);

console.log("🧩 Deduped missingDescProducts => ", JSON.stringify(missingDescProducts));

// 🔹 Build final list: matched products (by Id or Name), update qty & discount
var filteredBillList = [];
var extraQtyProducts = []; // store products with extra qty

if (missingDescProducts.length > 0) {
    filteredBillList = billList
        .map(function(item) {
            var match = missingDescProducts.find(function(prod) {
                // ✅ Match by Product Id OR by Name
                return (prod.idValue && prod.idValue === item.ERP7__Product__c) 
                    || (!prod.idValue && prod.keyName === item.Name);
            });

            if (match) {
                // deep copy to keep other fields intact
                var newItem = JSON.parse(JSON.stringify(item));

                // ✅ always update qty from merged missingDescProducts
                newItem.ERP7__Quantity__c = match.quantity;

               // ✅ Case 1: Product exists in PO by Id
if (match.idValue) {
    if (match.quantity > item.ERP7__Quantity__c) {
        var deltaQty = match.quantity - item.ERP7__Quantity__c;

        newItem.ERP7__Description__c =
            'The quantity of this item has been updated from ' +
            item.ERP7__Quantity__c + ' to ' + match.quantity +
            ' as per the bill uploaded, which is greater than the Purchase Order.';

        // 🔹 Check if product already exists in extraQtyProducts
        var existingExtra = extraQtyProducts.find(function(prod) {
            return prod.productName === match.keyName;
        });

        if (existingExtra) {
            // Add to existing qty
            existingExtra.extraQty += deltaQty;
        } else {
            // Push new product entry
            extraQtyProducts.push({
                productName: match.keyName,
                extraQty: deltaQty,
                unitPrice: item.ERP7__Amount__c,
            });
        }
    }
}

                // ✅ Case 2: Product matched only by text (Name, no Id)
                else {
                    newItem.ERP7__Description__c =
                        "This product '" + match.keyName +
                        "' is set as custom product because its not there in the system.";
                }

                return newItem;
            }
            return null; // skip non-matching
        })
        .filter(function(item) { return item !== null; });
}

console.log("✅ Final Bill List => ", JSON.stringify(filteredBillList));

console.log("➕ Extra Qty Products => ", JSON.stringify(extraQtyProducts));

// Save to component for UI use
component.set("v.extraQtyProducts", extraQtyProducts);



                                        // 🔹 Set only matched products
                                        component.set("v.billItems", filteredBillList);





                                //component.set("v.billItems",billList);
                                console.log('arshad before getPOLIDimeListhelper for PO');
                                
                                if(component.get("v.billItems") != null && component.get("v.billItems") != undefined){
                                    if(component.get("v.billItems.length") > 0){
                                        helper.getPOLIDimeListMultihelper(component,event,helper);
                                    }
                                }
                            }else{
                                helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_Bill_Has_Already_Been_Created'));
                                setTimeout(
                                    $A.getCallback(function() {
                                        $A.enqueueAction(component.get("c.cancelclick"));
                                    }), 3000
                                );
                                
                            }
                        }catch(e){
                            console.log('arshad err1',e);
                        }
                    }
                }  
            });
            $A.enqueueAction(fetchpoliAction);
        }catch(e){
            console.log('arshad err2',e);
        }
    },
    

    
    fetchMultiPoli : function(component, event, helper) {

        console.log('fetchMultiPoli called');
        try{
            var fetchpoliAction = component.get("c.fetch_Polis_Multi");
            fetchpoliAction.setParams({"Ids":component.get("v.POIdsList")});
            fetchpoliAction.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    var resultList = response.getReturnValue();
                    if(resultList.length > 0){
                        console.log('in here fetchpoliAction~>'+JSON.stringify(resultList));
                        try{
                            var po = JSON.parse(resultList[0]);
                            component.set("v.Bill.ERP7__Vendor__c", po.ERP7__Vendor__c);
                            //component.set("v.Bill.ERP7__Sales_Order__c", po.ERP7__Sales_Order__c);
                            component.set("v.Bill.ERP7__Vendor_Contact__c", po.ERP7__Vendor_Contact__c);
                            component.set("v.Bill.ERP7__Vendor_Address__c", po.ERP7__Vendor_Address__c);
                            //component.set("v.Bill.ERP7__Description__c", po.ERP7__Description__c);
                            //alert('PO Org : ' +po.ERP7__Organisation__c);
                            component.set("v.Bill.ERP7__Organisation__c", po.ERP7__Organisation__c);
                            var poliList = JSON.parse(resultList[1]);
                            var billingQty = JSON.parse(resultList[2]);
                            var PoList = JSON.parse(resultList[3]);
                            component.set("v.PoList", PoList);
                            //alert('1==>'+JSON.stringify(poliList));
                            if(!$A.util.isEmpty(poliList)){
                                var billList = [];//component.get("v.billItems");
                                for(var x in poliList){
                                    for(var y in billingQty){
                                        if(x == y){
                                            //Changes made by Arshad tp populate tax rate same as it is from poli, to handle even if partial bills qty created - 29-June-2023
                                            if(poliList[x].ERP7__Product__c == null || poliList[x].ERP7__Product__c == undefined){
                                                var obj = {ERP7__Chart_Of_Account__c:null,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,ERP7__Discount__c:0.00,
                                                           ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c};
                                                billList.push(obj);
                                            }else if(poliList[x].ERP7__Product__r.ERP7__Track_Inventory__c){
                                                console.log('poliList[x]~>'+JSON.stringify(poliList[x]));
                                                var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,
                                                           ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c};
                                                billList.push(obj);
                                            }else if(poliList[x].ERP7__Product__r.ERP7__Is_Asset__c){
                                                var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Asset_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,
                                                           ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c};
                                                billList.push(obj);
                                            }else{
                                                console.log('in here expense po');
                                                var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].Id,
                                                           ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Tax_Rate__c:poliList[x].ERP7__Tax_Rate__c};
                                                billList.push(obj);
                                            }
                                        }
                                    }
                                }     
                                component.set("v.billItems",billList);
                                console.log('arshad before getPOLIDimeListhelper for PO');
                                
                                if(component.get("v.billItems") != null && component.get("v.billItems") != undefined){
                                    if(component.get("v.billItems.length") > 0){
                                        helper.getPOLIDimeListMultihelper(component,event,helper);
                                    }
                                }
                            }else{
                                helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_Bill_Has_Already_Been_Created'));
                                setTimeout(
                                    $A.getCallback(function() {
                                        $A.enqueueAction(component.get("c.cancelclick"));
                                    }), 3000
                                );
                                
                            }
                        }catch(e){
                            console.log('arshad err1',e);
                        }
                    }
                }  
            });
            $A.enqueueAction(fetchpoliAction);
        }catch(e){
            console.log('arshad err2',e);
        }
    },
    
    updateDate : function(component,event,helper){
        var vBillDate = component.get("v.Bill.ERP7__Vendor_Bill_Date__c");
        if(!$A.util.isEmpty(vBillDate)){
            var parts =vBillDate.split('-');
            var dueDate = new Date(parts[0], parts[1] - 1, parts[2]); 
            dueDate.setDate(dueDate.getDate() + component.get("v.payTerms"));
            component.set("v.Bill.ERP7__Due_Date__c",dueDate.getFullYear() + "-" + (dueDate.getMonth() + 1) + "-" + dueDate.getDate());
        }
    },
    
    fetchVendorDetails  : function(component,event,helper){
        if((component.get('v.recordId') == undefined || component.get('v.recordId') == null || component.get('v.recordId') == '') || component.get('v.clone')){
            let vendorAction = component.get("c.getVendorDetails");
            var recID = component.get("v.Bill.ERP7__Vendor__c");
            if(!$A.util.isEmpty(recID)){
                vendorAction.setParams({"recordId":recID});
                vendorAction.setCallback(this,function(response){
                    if(response.getState() === 'SUCCESS'){
                        console.log('fetchVendorDetails~>'+response.getReturnValue());
                        //component.set("v.Bill.ERP7__Vendor__c",recID);
                        //var bill = component.get("v.Bill");
                        var dueDate = new Date();
                        var vBillDate = new Date();
                        if(!$A.util.isUndefined(response.getReturnValue().ERP7__Payment_Terms__c)){
                            dueDate.setDate(dueDate.getDate() + parseInt(response.getReturnValue().ERP7__Payment_Terms__c));
                            vBillDate.setDate(vBillDate.getDate());
                            component.set("v.payTerms",parseInt(response.getReturnValue().ERP7__Payment_Terms__c));
                        }
                        component.set("v.Bill.ERP7__Vendor_Bill_Date__c", vBillDate.getFullYear() + "-" + (vBillDate.getMonth() + 1) + "-" + vBillDate.getDate());
                        console.log('ERP7__Vendor_Bill_Date__c set here1~>'+component.get("v.Bill.ERP7__Vendor_Bill_Date__c"));
                        component.set("v.Bill.ERP7__Due_Date__c",dueDate.getFullYear() + "-" + (dueDate.getMonth() + 1) + "-" + dueDate.getDate()); //bill.ERP7__Due_Date__c = response.getReturnValue().ERP7__Payment_Terms__c;
                    }
                });
                $A.enqueueAction(vendorAction);
            }else
                component.set("v.Bill.ERP7__Vendor__c",'');
        }
    },
    
    onCheck: function(component,event,helper){
        var currBillTrye = event.currentTarget.getAttribute('data-billType');
        component.set('v.setRT',currBillTrye);
        component.set('v.ShowBillType',false);
        component.set('v.showPage',true);
        /* var poCheck=component.find('pOcheckbox').get("v.value");
         var billCheck=component.find('billcheckbox').get("v.value");
        var Advcheckbox=component.find('Advcheckbox').get("v.value");
       
         if(poCheck)component.set('v.setRT','PO Bill');
         if(billCheck)component.set('v.setRT','Expense Bill');
        if(Advcheckbox)component.set('v.setRT','Advance to vendor');
         component.set('v.ShowBillType',false);
         component.set('v.showPage',true);
         */
    },
    
    setpostFalse:function(component,event,helper){
        component.set('v.setBillPost',false);
    },
    
    setpostTrue:function(component,event,helper){
        component.set('v.setBillPost',true);
    },
    
    /*doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            alert('Please Select a Valid File');
        }
    },*/
    
   
//  removeAttachment: function(component, event, helper) {
//     console.log('removeAttachment called');
//     let current = component.get("v.isActive");

//     // 🔹 Common cleanup function
//     function resetFileState() {
//         component.set("v.showDelete", false);

//         var billItems = component.get("v.billItems") || [];
//         billItems.splice(0, billItems.length);
//         component.set("v.billItems", billItems);

//         component.set("v.FileList", []);
//         component.set("v.fillList", []);

//         let fileInput = component.find("fileId");
//         if (fileInput) {
//             fileInput.getElement().value = "";
//         }
//     }

//     console.log('Current Active State: ', current);

//     if (!current) {
//         console.log('In the !current block');
//         component.set("v.showDelete", false);
//         component.set("v.FileList", []);
//         component.set("v.fillList", []);

//         let fileInput = component.find("fileId");
//         if (fileInput) {
//             fileInput.getElement().value = "";
//         }

//     } else {
//         console.log('In the else block');
//         var existingPO = component.get("v.Bill.ERP7__Purchase_Order__c");
//         var multiplePOs = component.get("v.POIdsList");

//         console.log('Existing PO: ', existingPO);
//         console.log('Multiple POs: ', multiplePOs);
//         // Case 1: Single PO
//         if (existingPO) {
//             resetFileState();

//             helper.showToast(
//                 $A.get('$Label.c.Success'),
//                 'success',
//                 'The file has been removed, fetching the PO Bill details again.'
//             );

//             setTimeout(function() {
//                 var controllerMethod = component.get("c.fetchPolis");
//                 controllerMethod.setParams({ Id: existingPO });
//                 $A.enqueueAction(controllerMethod);
//             }, 2000);
//         }
//         // Case 2: Multiple POs
//         else if (multiplePOs && multiplePOs.length > 0) {
//             resetFileState();

//             console.log('Multiple POs exist, refetching details for all.');

//             helper.showToast(
//                 $A.get('$Label.c.Success'),
//                 'success',
//                 'The file has been removed, fetching the PO Bill details again.'
//             );

//             setTimeout(function() {
//                 var controllerMethod = component.get("c.fetchMultiPolis");
//                 controllerMethod.setParams({ POIds: multiplePOs });
//                 $A.enqueueAction(controllerMethod);
//             }, 2000);
//         }

//         // No PO selected
//         else {
//             resetFileState();

//             console.log('No PO selected, just resetting file state.');
//             helper.showToast(
//                 $A.get('$Label.c.Success'),
//                 'success',
//                 'The file has been removed. Please select a Purchase Order to fetch Bill details.'
//             );
//         }1
//     }
// },


removeAttachment: function(component, event, helper) {
    console.log('⚡ removeAttachment called');

    let current = component.get("v.isActive");
    console.log('Current Active State: ', current);

    if (!current) {
        console.log('ℹ In the !current block');
        helper.resetFileStateSafe(component);

    } else {
        console.log('ℹ In the else block');
        var existingPO = component.get("v.Bill.ERP7__Purchase_Order__c");
        var multiplePOs = component.get("v.POIdsList");

        console.log('➡ Existing PO: ', existingPO);
        console.log('➡ Multiple POs: ', multiplePOs);

        // Case 1: Single PO
        if (existingPO) {
            helper.resetFileStateSafe(component);

            helper.showToast(
                $A.get('$Label.c.Success'),
                'success',
                'The file has been removed, fetching the PO Bill details again.'
            );

            setTimeout(function() {
                try {
                    var controllerMethod = component.get("c.fetchPolis");
                    controllerMethod.setParams({ Id: existingPO });
                    $A.enqueueAction(controllerMethod);
                } catch (err) {
                    console.error('❌ Error in fetchPolis enqueue:', err);
                }
            }, 2000);
        }
        // Case 2: Multiple POs
        else if (multiplePOs && multiplePOs.length > 0) {
            helper.resetFileStateSafe(component);

            console.log('🔁 Multiple POs exist, refetching details for all.');

            helper.showToast(
                $A.get('$Label.c.Success'),
                'success',
                'The file has been removed, fetching the PO Bill details again.'
            );

            setTimeout(function() {
                try {
                    var controllerMethod = component.get("c.fetchMultiPolis");
                    controllerMethod.setParams({ POIds: multiplePOs });
                    $A.enqueueAction(controllerMethod);
                } catch (err) {
                    console.error('❌ Error in fetchMultiPolis enqueue:', err);
                }
            }, 2000);
        }
        // Case 3: No PO selected
        else {
            helper.resetFileStateSafe(component);

            console.log('⚠ No PO selected, just resetting file state.');
            helper.showToast(
                $A.get('$Label.c.Success'),
                'success',
                'The file has been removed. Please select a Purchase Order to fetch Bill details.'
            );
        }
    }
},

    
   

    navigatetoPO : function(component, event, helper) {
        var POId=component.get('v.Bill.ERP7__Purchase_Order__c');
        if(POId == undefined){
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_select_Purchase_Order'));
            return;
        }
        /*var evt = $A.get("e.force:navigateToComponent");
         evt.setParams({
             componentDef : "c:CreatePurchaseOrder",
             componentAttributes: {
                 recordId : component.get("v.Bill.ERP7__Purchase_Order__c"),
                 fromCB : "true"
             }
         });
         evt.fire();*/
        
        $A.createComponent("c:CreatePurchaseOrder",{
            recordId : component.get("v.Bill.ERP7__Purchase_Order__c"),
            fromCB : true
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        }); 
        
        /*var url = '/apex/ERP7__CreatePurchaseOrderLC?PoId=';
         url = url + component.get("v.Bill.ERP7__Purchase_Order__c");
         url = url + '&fromCB=true'
         window.location.replace(url);*/
        //window.open(url,"__self");
    },
    
      /* handleFilesChange: function(component, event, helper) {
        
        
        
     
        var billList = component.get("v.billItems");
        billList.push({sObjectType :'ERP7__Bill_Line_Item__c',Accounts : [], Category:'', AccAccount:''});
        var Billobj = component.get("v.Bill");
        for(var x in billList){
            billList[x].ERP7__Quantity__c = 5;
            billList[x].ERP7__Amount__c = 20.5;
            billList[x].ERP7__Product__c = '01t0600000D1finAAB';
        }
        component.set("v.billItems", billList);
        billList = component.get("v.billItems");
        billList.push({sObjectType :'ERP7__Bill_Line_Item__c',Accounts : [], Category:'', AccAccount:''});
        for(var x in billList){
            if(x!=0){
                billList[x].ERP7__Quantity__c = 6;
                billList[x].ERP7__Amount__c = 27.5;
                billList[x].ERP7__Product__c = '01t1o00000BAqoDAAT';
            }
        }
        component.set("v.billItems", billList);
        Billobj.ERP7__Vendor__c = '0010600002Hg6KVAAZ';
        Billobj.ERP7__Vendor_Contact__c = '0030600002GDfp3AAD';
        Billobj.ERP7__Vendor_Address__c = 'a00J6000001nAoBIAU';
        Billobj.ERP7__Vendor_Bill_Number__c = 'CR-0001-3456723467';
        var dueDate = new Date();
        var vBillDate = new Date();
        component.set("v.Bill.ERP7__Vendor_Bill_Date__c", vBillDate.getFullYear() + "-" + (vBillDate.getMonth() + 1) + "-" + vBillDate.getDate());
        console.log('ERP7__Vendor_Bill_Date__c set here1~>'+component.get("v.Bill.ERP7__Vendor_Bill_Date__c"));
        component.set("v.Bill.ERP7__Due_Date__c",dueDate.getFullYear() + "-" + (dueDate.getMonth() + 1) + "-" + dueDate.getDate()); 
        component.set("v.Bill", Billobj);
        component.set("v.showDelete",true);
        var fileName = 'No File Selected..';
        //var files = component.get("v.FileList");  
        
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            var fileItem = [];
            for(var i=0;i<event.getSource().get("v.files").length;i++){
                fileItem.push(event.getSource().get("v.files")[i]['name']);
            }
        }
        //alert(fileItem);
        component.set("v.fillList",fileItem);
        component.set("v.fileName", fileName);
    }, */
    
    updateTDS : function(cmp, e, h){
        
        var tds_rate = cmp.get('v.TDS_Rate');
        
        if(tds_rate==undefined || tds_rate==null)tds_rate=0
        var TDS_Amount =0;
        if(tds_rate>0)TDS_Amount=(cmp.get('v.Bill.ERP7__Amount__c')/100)*tds_rate;
        cmp.set('v.Bill.ERP7__TDS_Amount__c',TDS_Amount);
    },
    
    cancelclick : function(cmp,event,helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Accounts_Payable",
            componentAttributes: {
                "selectedTab" : 'Bills'
            }
        });
        evt.fire();
        
    },


    
    UpdateOA: function(component,event,helper){
        if(component.get('v.recordId') == null || component.get('v.recordId') == '' || component.get('v.recordId') == undefined){
            console.log('UpdateOA called');
            if(component.get("v.Bill.ERP7__Organisation__c") != null && component.get("v.Bill.ERP7__Organisation__c") != undefined && component.get('v.setRT')=='Expense Bill'){
                var isMulticurrency = component.get('v.isMultiCurrency');
                if(isMulticurrency == true) { 
                    helper.fetchOrgCurrncy(component,event,helper); 
                }
            }
        }
    },
    
    imageError: function(component,event,helper){
        console.log('imageError called');
        event.target.style.display = 'none';
    },  
    
    // DeleteRecordAT: function(component, event) {
    //     var result = confirm("Are you sure?");
    //     console.log('result : ',result);
    //     var RecordId = event.getSource().get("v.name");
    //     console.log('RecordId : ',RecordId);
    //     var parentId = event.getSource().get("v.title");
    //     console.log('parentId : ',parentId);
    //     if (result) {
    //         //window.scrollTo(0, 0);
    //         //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
    //         try{
    //             var action = component.get("c.DeleteAttachment");
    //             action.setParams({
    //                 attachId: RecordId,
    //                 parentId: parentId,
    //             });
    //             action.setCallback(this, function(response) {
    //                 if (response.getState() === "SUCCESS") {
    //                     console.log("DeleteRecordAT resp: ", JSON.stringify(response.getReturnValue()));
    //                     component.set('v.uploadedFile',response.getReturnValue());
    //                     $A.util.addClass(component.find('mainSpin'), "slds-hide");
    //                 }
    //                 else{
    //                     $A.util.addClass(component.find('mainSpin'), "slds-hide");
    //                     var errors = response.getError();
    //                     console.log("server error in doInit : ", JSON.stringify(errors));
    //                     component.set("v.exceptionError", errors[0].message);
    //                 }
    //             });
    //             $A.enqueueAction(action);
    //         }
    //         catch(err) {
    //             console.log('Exception : ',err);
    //         }
    //     } 
    // },
    


    //**************************************the working one with fetch after delete************************************************
        // DeleteRecordAT: function(component, event) {
        //     var result = confirm("Are you sure?");
        //     console.log('result : ', result);

        //     var RecordId = event.getSource().get("v.name");   
        //     var parentId = event.getSource().get("v.title"); 
        //     console.log('RecordId : ', RecordId);
        //     console.log('parentId : ', parentId);

        //     if (result) {
        //         try {
        //             // Call the Apex delete method
        //             var action = component.get("c.DeleteAttachment");
        //             action.setParams({
        //                 attachId: RecordId || '',   
        //                 parentId: parentId || ''
        //             });

        //             action.setCallback(this, function(response) {
        //                 var state = response.getState();
        //                 console.log("DeleteRecordAT state: ", state);

        //                 if (state === "SUCCESS") {
        //                     console.log("DeleteRecordAT resp: ", JSON.stringify(response.getReturnValue()));
        //                     $A.util.addClass(component.find('mainSpin'), "slds-hide");

        //                     var fetchAction = component.get("c.getAllDocs");
        //                     fetchAction.setParams({ parentId: parentId });
        //                     fetchAction.setCallback(this, function(fetchResponse) {
        //                         var fetchState = fetchResponse.getState();
        //                         if (fetchState === "SUCCESS") {
        //                             var allDocs = fetchResponse.getReturnValue();
        //                             console.log("All Docs & Attachments (JSON): ", JSON.stringify(allDocs, null, 2));
        //                         } else {
        //                             console.error("Error fetching docs: ", JSON.stringify(fetchResponse.getError()));
        //                         }
        //                     });
        //                     $A.enqueueAction(fetchAction);
        //                     // 🔼 END NEW PART

        //                     // Update file list if needed
        //                     component.set('v.uploadedFile', response.getReturnValue());
        //                 } 
        //                 else {
        //                     $A.util.addClass(component.find('mainSpin'), "slds-hide");
        //                     var errors = response.getError();
        //                     console.error("Server error in DeleteRecordAT: ", JSON.stringify(errors));
        //                     component.set("v.exceptionError", (errors && errors[0] && errors[0].message) || 'Unknown error');
        //                 }
        //             });

        //             $A.enqueueAction(action);
        //         } 
        //         catch (err) {
        //             console.error('Exception in DeleteRecordAT: ', err);
        //             alert('Unexpected error: ' + err.message);
        //         }
        //     }
        // },
//************************************************************************************************ 

    DeleteRecordAT: function(component, event) {
        var ok = confirm("Are you sure?");
        if (!ok) return;

        var recordId = event.getSource().get("v.name");   // the file/attachment Id (string)
        var parentId = event.getSource().get("v.title");  // record Id (if you need to log)
        console.log('[DeleteRecordAT] mark for delete:', recordId, 'parent:', parentId);

        // 1) stash for later delete
        var pending = component.get('v.deletedFiles') || [];
        if (recordId && !pending.includes(recordId)) {
            pending.push(recordId);
            component.set('v.deletedFiles', pending);
            component.set('v.deleteRequested', true); // flag
            console.log('Pending deletes updated:', pending);
            
        }

        // // 2) remove from UI list (uploadedFile is String[])
        // var files = component.get('v.uploadedFile') || [];
        // files = files.filter(function(id){ return id !== recordId; });
        // component.set('v.uploadedFile', files);

        // console.log('Updated uploadedFile list:', files);

        // // 3) log JSON
        // console.log('Pending deletes JSON:', JSON.stringify({ deletedFiles: pending }, null, 2));
        // 2) Remove from UI list (uploadedFile is String[])
      // 1) Get current file Id and existing list
var recordId = event.getSource().get("v.name");
var files = component.get("v.uploadedFile") || [];

// 2) Normalize to plain IDs (since uploadedFile is String[])
var fileIds = files.map(function(item){
    if (typeof item === "string") {
        return item.trim();
    } else if (item && typeof item === "object") {
        // convert object to its Id
        return (item.Id || item.ContentDocumentId || '').trim();
    }
    return '';
}).filter(Boolean);

// 3) Remove the one we "deleted"
var updated = fileIds.filter(function(id){
    return id !== recordId;
});

// 4) Update component value (forces rerender)
component.set("v.uploadedFile", updated);
console.log("UI updated. New uploadedFile list:", JSON.stringify(updated));


    },


    // SaveButtonForManageBillDoc: function(component, event, helper) {
    //     var parentId = component.get('v.recordId'); // or however you store it
    //     var queue = (component.get('v.deletedFiles') || []).slice(); // copy

    //     if (!queue.length) {
    //         console.log('[SaveButton] nothing to delete');
    //         return;
    //     }

    //     console.log('[SaveButton] deleting:', JSON.stringify(queue));

    //     var next = function() {
    //         if (!queue.length) {
    //             component.set('v.deletedFiles', []); // clear after success
    //             console.log('[SaveButton] delete complete');
    //             return;
    //         }
    //         var idToDelete = queue.shift();
    //         var action = component.get('c.DeleteAttachment'); // SAME Apex
    //         action.setParams({
    //             attachId: idToDelete,
    //             parentId: parentId || ''
    //         });
    //         action.setCallback(this, function(r){
    //             var st = r.getState();
    //             if (st !== 'SUCCESS') {
    //                 console.error('[SaveButton] failed for', idToDelete, r.getError && r.getError());
    //                 // continue regardless
    //             } else {
    //                 console.log('[SaveButton] deleted on server:', idToDelete);
    //             }
    //             next(); // process next
    //         });
    //         $A.enqueueAction(action);
    //     };

    //     next();
    // },


    
    // Code forthe OCR part by saqlain khan
    
    onScriptsLoaded: function(component, event, helper) {
        console.log('Script Loaded');
    },

    onScriptsLoaded1: function(component, event, helper) {
        console.log('Script Loaded 1');
        globalThis = window;
        var workerSrcUrl = $A.get('$Resource.PDFReaderWorkerJS');
        pdfjsLib.GlobalWorkerOptions.workerSrc = workerSrcUrl;
    },
    
    


    closeModal: function (component, event, helper) {
    // Set the showModal attribute to false to close the modal
    component.set("v.showModal", false);
},
    

     toggleOCR : function(component, event, helper) {
        let current = component.get("v.isActive");
        component.set("v.isActive", !current);
        if (!current){
        helper.showToast($A.get('$Label.c.Success'),'success', 'Make sure to uploaded file should have a PO number in it and related line items.');

        }

        helper.showToast($A.get('$Label.c.Success'),'success', ' OCR is now ' + (!current ? 'enabled' : 'disabled') + '.');



    },
    
handleFilesChange: function (component, event, helper) {

    
    // 1️⃣ Clear any previously uploaded files
    var existingFiles = component.get('v.uploadedFile');
    if (existingFiles && existingFiles.length > 0) {
        console.log('[handleFilesChange] clearing old uploaded files:', JSON.stringify(existingFiles));
        component.set('v.uploadedFile', []); // clear the list
    }

    const isReadBillChecked = component.get("v.isReadBillChecked");
    const setRT = component.get("v.setRT");
    const isactive = component.get("v.isActive");
    if (isReadBillChecked && setRT == 'PO Bill' && isactive) {
        const fileInput = event.getSource().get("v.files")[0];
        if (fileInput) {
            component.set("v.recentFileData", fileInput);
            component.set("v.selectedFile", fileInput);
        $A.enqueueAction(component.get("c.createNewBill"));

        } else {
            alert("Please select a valid file.");
        }
    } else {
        component.set("v.showDelete", true);
        let fileName = 'No File Selected..';
        const files = event.getSource().get("v.files");
        if (files.length > 0) {
            fileName = files[0]['name'];
            const fileItem = [];
            let totalRequestSize = 0;

            for (let i = 0; i < files.length; i++) {
                const file = files[i];
                const fileSize = file.size;

                if (fileSize > 2000000) {
                    helper.showToast('Error', 'error', 'File ' + file.name + ' exceeds the 2 MB limit.');
                     component.set("v.fillList", []);
            component.set("v.fileName", []);
                    component.set("v.showDelete", false);
                    return;
                    
                }

                totalRequestSize += fileSize;

                if (totalRequestSize > 6000000) {
                    helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                    component.set("v.fillList", []);
            component.set("v.fileName", []);
                    component.set("v.showDelete", false);
                    return;
                }

                fileItem.push(file.name);
            }

            component.set("v.fillList", fileItem);
            component.set("v.fileName", fileName);
        }
    }
},
    
alterBill: function (component, event, helper) {
    try {
        const fileInput = component.get("v.selectedFile");
        if (fileInput) {
            // Process the file using helper logic
            component.set("v.showDelete", true);
            helper.processFile(fileInput, component, helper);
        }
        // Close the modal
        component.set("v.showModal", false);
    } catch (error) {
        console.error("Error in alterBill:", error);
    }
},


createNewBill: function (component, event, helper) {
    try {
        const fileInput = component.get("v.selectedFile");
        if (fileInput) {
            // Clear existing bill items
            let billItems = component.get("v.billItems");
            billItems.splice(0, billItems.length); // Removes all items from billItems
            component.set("v.billItems", billItems);

            // Process the new file
            component.set("v.showDelete", true);
            helper.processFile(fileInput, component, helper);
        }
        // Close the modal
        component.set("v.showModal", false);
    } catch (error) {
        console.error("Error in createNewBill:", error);
    }
},

createPurchaseOrderNew : function(component, event, helper) {
    // ✅ Get the billPayload we set earlier
    var billPayload = component.get("v.billPayload");

    // Create the CreatePurchaseOrder component and pass billPayload into it
    $A.createComponent(
        "c:CreatePurchaseOrder",
        {
            "billPayload": billPayload,   // 🔹 Passing the full payload
            "cancelclick": component.getReference("c.backtobill"),
            "showPOType": false

        },
        function(newCmp, status, errorMessage) {
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            } else {
                console.error("Error while creating component:", errorMessage);
            }
        }
    );
},

backtobill : function(component,event,helper){
    console.log("Navigating to Bills tab");
    var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
        componentDef : "c:Accounts_Payable",
        componentAttributes: {
            "selectedTab" : 'Bills'
        }
    });
    evt.fire();
}



    

})