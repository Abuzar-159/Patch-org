({
    doInit: function(component, event, helper) {
       
        component.set("v.totalTax",component.get("v.invoiceLineItem.ERP7__Other_Tax__c")+component.get("v.invoiceLineItem.ERP7__VAT_Amount__c"));
        var tax;
        tax=(component.get("v.invoiceLineItem.ERP7__Other_Tax__c")+component.get("v.invoiceLineItem.ERP7__VAT_Amount__c"))/component.get("v.invoiceLineItem.ERP7__Quantity__c");
        component.set("v.taxPerQuantity",tax);//component.get("v.invoiceLineItem.ERP7__Other_Tax__c"));
        component.set('v.subTotalPrice',component.get('v.invoiceLineItem.ERP7__Sub_Total__c'));
        
        var vatTax=component.get("v.invoiceLineItem.ERP7__VAT_Amount__c")/component.get("v.invoiceLineItem.ERP7__Quantity__c");
        component.set('v.vatTax',vatTax);
        var otherTax=component.get("v.invoiceLineItem.ERP7__Other_Tax__c")/component.get("v.invoiceLineItem.ERP7__Quantity__c");
        component.set('v.otherTax',otherTax);
       // component.set("v.invoiceLineItem.ERP7__VAT_Amount__c",component.get("v.invoiceLineItem.ERP7__Other_Tax__c")+component.get("v.invoiceLineItem.ERP7__VAT_Amount__c"));
        component.set("v.discount",component.get("v.invoiceLineItem.ERP7__Discount_Amount__c")/component.get("v.invoiceLineItem.ERP7__Quantity__c"));
        var Quantity;
        if(!$A.util.isEmpty(component.get("v.SOId")))
        	Quantity=component.get("v.invoiceLineItem.ERP7__Sales_Order_Line_Item__r.ERP7__Quantity__c")-component.get("v.invoiceLineItem.ERP7__Sales_Order_Line_Item__r.ERP7__Invoiced_Quantity__c");
        else if(!$A.util.isEmpty(component.get("v.StdId")))
            Quantity=component.get("v.invoiceLineItem.ERP7__Order_Product__r.Quantity")-component.get("v.invoiceLineItem.ERP7__Order_Product__r.ERP7__Invoiced_Quantity__c");
                
        component.set("v.Qty",Quantity);
    },
  /*  updateCalculations : function(component, event, helper) {
        console.log('updateCalculations');
        if(!$A.util.isEmpty(component.get("v.SOId"))){
            if(component.get("v.invoiceLineItem.ERP7__Quantity__c") <= component.get("v.invoiceLineItem.ERP7__Sales_Order_Line_Item__r.ERP7__Quantity__c")){
                if(component.get("v.invoiceLineItem.ERP7__Quantity__c")>0) 
                    var discount=component.get("v.discount")*component.get("v.invoiceLineItem.ERP7__Quantity__c");
                else 
                    component.set("v.invoiceLineItem.ERP7__Discount_Amount__c",0);
                if(discount!=undefined) component.set("v.invoiceLineItem.ERP7__Discount_Amount__c",discount);
                component.set("v.invoiceLineItem.ERP7__Sub_Total__c",parseFloat(component.get("v.invoiceLineItem.ERP7__Quantity__c") * component.get("v.invoiceLineItem.ERP7__Unit_Price__c")));
                var totalVatTax=component.get('v.vatTax')*component.get("v.invoiceLineItem.ERP7__Quantity__c");
                component.set("v.invoiceLineItem.ERP7__VAT_Amount__c",totalVatTax);//parseFloat(component.get("v.invoiceLineItem.ERP7__Quantity__c") * component.get("v.taxPerQuantity")));
                
                var totalOtherTax=component.get('v.otherTax')*component.get("v.invoiceLineItem.ERP7__Quantity__c");
                component.set("v.invoiceLineItem.ERP7__Other_Tax__c",totalOtherTax);//parseFloat(component.get("v.invoiceLineItem.ERP7__Quantity__c") * component.get("v.taxPerQuantity")));
                var totalTax=totalOtherTax+totalVatTax;
                //component.set("v.totalTax",totalTax);
                //component.set("v.invoiceLineItem.ERP7__Other_Tax__c",parseFloat(component.get("v.invoiceLineItem.ERP7__Quantity__c") * component.get("v.taxPerQuantity")));
                component.set("v.invoiceLineItem.ERP7__Total_Price__c",parseFloat(totalTax + component.get("v.invoiceLineItem.ERP7__Sub_Total__c")));
                component.set("v.subTotalPrice",parseFloat(component.get("v.invoiceLineItem.ERP7__Total_Price__c")));
                var callToupdatePrice=component.get('v.callToupdatePrice')+1;
                component.set('v.callToupdatePrice',callToupdatePrice);
            }
        }
        else if(!$A.util.isEmpty(component.get("v.StdId"))){
            if(component.get("v.invoiceLineItem.ERP7__Quantity__c") <= component.get("v.invoiceLineItem.ERP7__Order_Product__r.Quantity")){
                if(component.get("v.invoiceLineItem.ERP7__Quantity__c")>0) 
                    var discount=component.get("v.discount")*component.get("v.invoiceLineItem.ERP7__Quantity__c");
                else 
                    component.set("v.invoiceLineItem.ERP7__Discount_Amount__c",0);
                if(discount!=undefined) component.set("v.invoiceLineItem.ERP7__Discount_Amount__c",discount);
                component.set("v.invoiceLineItem.ERP7__Sub_Total__c",parseFloat(component.get("v.invoiceLineItem.ERP7__Quantity__c") * component.get("v.invoiceLineItem.ERP7__Unit_Price__c")));
                var totalVatTax=component.get('v.vatTax')*component.get("v.invoiceLineItem.ERP7__Quantity__c");
                component.set("v.invoiceLineItem.ERP7__VAT_Amount__c",totalVatTax);//parseFloat(component.get("v.invoiceLineItem.ERP7__Quantity__c") * component.get("v.taxPerQuantity")));
                
                var totalOtherTax=component.get('v.otherTax')*component.get("v.invoiceLineItem.ERP7__Quantity__c");
                component.set("v.invoiceLineItem.ERP7__Other_Tax__c",totalOtherTax);//parseFloat(component.get("v.invoiceLineItem.ERP7__Quantity__c") * component.get("v.taxPerQuantity")));
                var totalTax=totalOtherTax+totalVatTax;
                //component.set("v.totalTax",totalTax);
                //component.set("v.invoiceLineItem.ERP7__Other_Tax__c",parseFloat(component.get("v.invoiceLineItem.ERP7__Quantity__c") * component.get("v.taxPerQuantity")));
                 component.set("v.invoiceLineItem.ERP7__Total_Price__c",parseFloat(totalTax + component.get("v.invoiceLineItem.ERP7__Sub_Total__c")));
                component.set("v.subTotalPrice",parseFloat(component.get("v.invoiceLineItem.ERP7__Total_Price__c")));
                var callToupdatePrice=component.get('v.callToupdatePrice')+1;
                component.set('v.callToupdatePrice',callToupdatePrice);
            }
        }
        
    }, */
    
    
   updateCalculations : function(component, event, helper) {
    console.log('--- updateCalculations called ---');

    if (!$A.util.isEmpty(component.get("v.SOId"))) {
        console.log('SOId found');

        var qty = component.get("v.invoiceLineItem.ERP7__Quantity__c");
        var availableQty = component.get("v.invoiceLineItem.ERP7__Sales_Order_Line_Item__r.ERP7__Quantity__c");
        console.log('Qty:', qty, 'Available Qty:', availableQty);

        if (qty <= availableQty) {
            if (qty > 0) {
                var discount = component.get("v.discount") * qty;
                component.set("v.invoiceLineItem.ERP7__Discount_Amount__c", discount);
                console.log('Discount:', discount);
            } else {
                component.set("v.invoiceLineItem.ERP7__Discount_Amount__c", 0);
                console.log('Qty is 0, discount set to 0');
            }

            var unitPrice = component.get("v.invoiceLineItem.ERP7__Unit_Price__c");
            var subTotal = parseFloat(qty * unitPrice);
            component.set("v.invoiceLineItem.ERP7__Sub_Total__c", subTotal);
            console.log('Sub Total:', subTotal);

            var totalVatTax = component.get('v.vatTax') * qty;
            var totalOtherTax = component.get('v.otherTax') * qty;
            component.set("v.invoiceLineItem.ERP7__VAT_Amount__c", totalVatTax);
            component.set("v.invoiceLineItem.ERP7__Other_Tax__c", totalOtherTax);
            console.log('VAT Tax:', totalVatTax, 'Other Tax:', totalOtherTax);

            var totalTax = totalVatTax + totalOtherTax;
            var totalPrice = parseFloat(subTotal + totalTax);
            component.set("v.invoiceLineItem.ERP7__Total_Price__c", totalPrice);
            component.set("v.subTotalPrice", totalPrice);
            console.log('Total Price:', totalPrice);

          // Down Payment Calculation
var downPaymentAmt = component.get("v.downPaymentAmount");
var downPaymentPct = component.get("v.downPaymentPercentage");
console.log('DP Amount:', downPaymentAmt, 'DP Percent:', downPaymentPct);

if (downPaymentPct && downPaymentPct >= 1 && downPaymentPct <= 100) {
    var calculatedAmt = (totalPrice * downPaymentPct) / 100;

    component.set("v.invoiceLineItem.ERP7__Down_Payment__c", downPaymentPct);
    component.set("v.invoiceLineItem.ERP7__Total_Down_Payment_Amount__c", calculatedAmt);

    //  Sync both values to parent
    component.set("v.downPaymentAmount", calculatedAmt);
    component.set("v.downPaymentPercentage", downPaymentPct);

    console.log('DP % used. Amount Calculated:', calculatedAmt);
}
else if (downPaymentAmt) {
    var calculatedPct = ((downPaymentAmt / totalPrice) * 100).toFixed(2);

    component.set("v.invoiceLineItem.ERP7__Down_Payment__c", calculatedPct);
    component.set("v.invoiceLineItem.ERP7__Total_Down_Payment_Amount__c", downPaymentAmt);

    //  Sync both values to parent
    component.set("v.downPaymentAmount", downPaymentAmt);
    component.set("v.downPaymentPercentage", calculatedPct);

    console.log('DP Amt used. Percent Calculated:', calculatedPct);
}

            var callToupdatePrice = component.get('v.callToupdatePrice') + 1;
            component.set('v.callToupdatePrice', callToupdatePrice);
        }
    }

    else if (!$A.util.isEmpty(component.get("v.StdId"))) {
        console.log('StdId found');

        var qty = component.get("v.invoiceLineItem.ERP7__Quantity__c");
        var availableQty = component.get("v.invoiceLineItem.ERP7__Order_Product__r.Quantity");
        console.log('Qty:', qty, 'Available Qty:', availableQty);

        if (qty <= availableQty) {
            if (qty > 0) {
                var discount = component.get("v.discount") * qty;
                component.set("v.invoiceLineItem.ERP7__Discount_Amount__c", discount);
                console.log('Discount:', discount);
            } else {
                component.set("v.invoiceLineItem.ERP7__Discount_Amount__c", 0);
                console.log('Qty is 0, discount set to 0');
            }

            var unitPrice = component.get("v.invoiceLineItem.ERP7__Unit_Price__c");
            var subTotal = parseFloat(qty * unitPrice);
            component.set("v.invoiceLineItem.ERP7__Sub_Total__c", subTotal);
            console.log('Sub Total:', subTotal);

            var totalVatTax = component.get('v.vatTax') * qty;
            var totalOtherTax = component.get('v.otherTax') * qty;
            component.set("v.invoiceLineItem.ERP7__VAT_Amount__c", totalVatTax);
            component.set("v.invoiceLineItem.ERP7__Other_Tax__c", totalOtherTax);
            console.log('VAT Tax:', totalVatTax, 'Other Tax:', totalOtherTax);

            var totalTax = totalVatTax + totalOtherTax;
            var totalPrice = parseFloat(subTotal + totalTax);
            component.set("v.invoiceLineItem.ERP7__Total_Price__c", totalPrice);
            component.set("v.subTotalPrice", totalPrice);
            console.log('Total Price:', totalPrice);

            // Down Payment Calculation
            var downPaymentAmt = component.get("v.downPaymentAmount");
            var downPaymentPct = component.get("v.downPaymentPercentage");
            console.log('DP Amount:', downPaymentAmt, 'DP Percent:', downPaymentPct);

            if (downPaymentPct && downPaymentPct >= 1 && downPaymentPct <= 100) {
                var calculatedAmt = (totalPrice * downPaymentPct) / 100;
                component.set("v.invoiceLineItem.ERP7__Down_Payment__c", downPaymentPct);
                component.set("v.invoiceLineItem.ERP7__Total_Down_Payment_Amount__c", calculatedAmt);
                component.set("v.downPaymentAmount", calculatedAmt); // Sync back to parent
                console.log('DP % used. Amount Calculated:', calculatedAmt);
            } else if (downPaymentAmt) {
                var calculatedPct = ((downPaymentAmt / totalPrice) * 100).toFixed(2);
                component.set("v.invoiceLineItem.ERP7__Down_Payment__c", calculatedPct);
                component.set("v.invoiceLineItem.ERP7__Total_Down_Payment_Amount__c", downPaymentAmt);
                component.set("v.downPaymentPercentage", calculatedPct); // Sync back to parent
                console.log('DP Amt used. Percent Calculated:', calculatedPct);
            }

            var callToupdatePrice = component.get('v.callToupdatePrice') + 1;
            component.set('v.callToupdatePrice', callToupdatePrice);
        }
    }
},

    
    
    
    validate: function(component, event, helper) {
        	var requiredFields = component.find("requiredField");
        
        if(component.get("v.validate")){
            requiredFields.checkValidity();
            component.set("v.validate",requiredFields.get("v.validity").valid);
       }
    },
    
    handleCheckboxChange: function(component, event, helper) {
        // Get the checkbox value
        var isChecked = event.getSource().get("v.checked");
        
        // Update the value in invoiceLineItem
        var invoiceLineItem = component.get("v.invoiceLineItem");
        invoiceLineItem.ERP7__Account_COGS__c = isChecked;
        component.set("v.invoiceLineItem", invoiceLineItem);
        
        // Optional: Debug log
        console.log("Updated ERP7__Account_COGS__c to: ", isChecked);
    }


    
})