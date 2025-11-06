({
    getInstancesAndRecordTypes : function(comp, event, helper) {

        var action = comp.get("c.getInvoiceRecordType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (comp.isValid() && state === "SUCCESS") {

                comp.set("v.Invoice",response.getReturnValue().InvoiceRecord);
                comp.set("v.InvoiceRTList",response.getReturnValue().InvoiceRTList);
                console.log('InvoiceRTList~>'+JSON.stringify(response.getReturnValue().InvoiceRTList));
                if(comp.get("v.InvoiceRTList").length ==1){
                    let valArr = comp.get("v.InvoiceRTList")[0].split('@');
                    if(valArr.length>1){
                        comp.set("v.selectedrecordTypeMap",{'RecordTypeId':valArr[0],'DeveloperName':valArr[1]});
                    }
                }
                if (comp.get("v.MultiOrder") == true) {
                    let valArr = comp.get("v.InvoiceRTList");
                    let selectedRecordTypeMap;
                    console.log('valArr ' + JSON.stringify(valArr));
                    for (let x in valArr) {
                        var valu = valArr[x].value;
                        let Rec = valu.split('@');
                        console.log('Rec' + JSON.stringify(Rec));
                        if (Rec[1] === 'Sale') {
                            selectedRecordTypeMap = { 'RecordTypeId': Rec[0], 'DeveloperName': Rec[1] };
                            break; // Exit the loop after the first match
                        }
                    }

                    if (selectedRecordTypeMap) {
                        comp.set("v.selectedrecordTypeMap", selectedRecordTypeMap);
                    }
                    console.log('comp.set("v.selectedrecordTypeMap")' + JSON.stringify(comp.get("v.selectedrecordTypeMap")));
                }
            }else{
                console.log('Error:',response.getError());
            }

        });
        $A.enqueueAction(action);
    },


    getAccountInformation:function(c,recId){

        var a  = c.get("c.fetchAccountDetails");
        a.setParam('recordId',recId);
        a.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var obj = response.getReturnValue();
                var renderedFields = c.find("inv_input_field");
                for(var  x in renderedFields){
                    if(obj.hasOwnProperty(renderedFields[x].get('v.fieldName')))
                        renderedFields[x].set("v.value",obj[renderedFields[x].get('v.fieldName')]);

                }
            }else{
                console.log('Error:',response.getError());
            }
        });
        $A.enqueueAction(a);
    },
    CreateInvoiceAndLineItem : function(comp, event, helper) {
        try{
            var INVLIList;
            console.log('inside the try funtion -- INVLIList --> ',INVLIList);

            if(comp.get("v.selectedrecordTypeMap.DeveloperName")==='On_Account_Payment'){
                INVLIList = comp.get("v.INVLIList");
                console.log('here 1 INVLIList --> ',INVLIList);
            }else{
                INVLIList = comp.get("v.actualInvLI");
                console.log('here 2 INVLIList -->',INVLIList);

            }

            for(var x =0 ;x<INVLIList.length;x++){
                console.log('Inside for loop ');
                //INVLIList[x].ERP7__Invoice__c = comp.get("v.invrecordId");
                if(!$A.util.isEmpty(comp.get("v.SOId")))
                    INVLIList[x].ERP7__Sales_Order_Line_Item__r.ERP7__Invoiced_Quantity__c+=parseFloat(INVLIList[x].ERP7__Quantity__c);
					console.log('printing data on for loop INVLIList SOId --> ', JSON.stringify(INVLIList));
                if(!$A.util.isEmpty(comp.get("v.StdId")))
                    INVLIList[x].ERP7__Order_Product__r.ERP7__Invoiced_Quantity__c+=parseFloat(INVLIList[x].ERP7__Quantity__c);
                console.log('printing data on for loop INVLIList StdId --> ', JSON.stringify(INVLIList));

            }

            if(comp.get('v.enableShippingAmount') && comp.get('v.enableShipping') && comp.get('v.salesorder.ERP7__Total_Shipping_Amount__c')>0
               && comp.get('v.selectedrecordTypeMap.DeveloperName')!='Advance'){
                comp.set('v.salesorder.ERP7__Include_Shipping_Amount__c',true);
            }
            console.log('Invoice record:',JSON.stringify(comp.get("v.NewInvoice")));
            var action = comp.get("c.getCreateInvoiceAndLineItemUpdated");
            action.setParams({
                Invoice : JSON.stringify(comp.get("v.NewInvoice")),
                InvoiceLineItem:JSON.stringify(INVLIList),
                SO:JSON.stringify(comp.get('v.salesorder')),
                SOId:comp.get("v.SOId"),
                StdId:comp.get("v.StdId"),
                invType:comp.get('v.selectedrecordTypeMap.DeveloperName')
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (comp.isValid() && state === "SUCCESS") {
                    if(comp.get("v.FromAR")){
                        var actionInvName = comp.get("c.getInvoiceName");
                        actionInvName.setParams({ InvId: response.getReturnValue() });
                        actionInvName.setCallback(this, function (response) {
                            var InvName = response.getReturnValue();
                            $A.createComponent(
                                "c:AccountsReceivable", {
                                    "showTabs": 'inv',   //comp.get("v.showTabs")=='ord'? 'inv' : comp.get("v.showTabs")
                                    "fetchRecordsBool":false,
                                    "Organisation":comp.get("v.Organisation"),
                                    "Order":'DESC',
                                    "setSearch": InvName,
                                     "OrderBy":'CreatedDate'
                                },
                                function(newComp) {
                                    var content = comp.find("body");
                                    content.set("v.body", newComp);
                                }
                            );
                        });
                        $A.enqueueAction(actionInvName);
                    }else if(comp.get("v.fromProject")){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:Milestones",
                            componentAttributes: {
                                "currentProj" : comp.get("v.currentProj"),
                                "projectId" : comp.get("v.ProjId"),
                                "newProj" : false
                            }
                        });
                        evt.fire();
                    }else {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        if(!$A.util.isUndefined(navEvt)){
                            navEvt.setParams({
                                "recordId": response.getReturnValue(),
                            });
                            navEvt.fire();
                        }else{
                            window.open("/"+response.getReturnValue(),"_self");
                        }

                    }
                }else{
                    console.log('Error:',response.getError());
                    var errors = response.getError();
                    var pageerros = errors[0].pageErrors;
                    comp.set("v.showToast",true);
                    comp.set("v.message",pageerros[0].message);

                    setTimeout(
                        $A.getCallback(function() {
                            comp.set("v.showToast",false);
                        }), 10000
                    );
                    comp.set("v.showMmainSpin",false);
                }
            });
            $A.enqueueAction(action);
        }catch(e){
            console.log('err'+JSON.stringify(e))
        }
    },

    updateTotalPrice_Handler : function(component){
        try{
            var invli = component.get("v.actualInvLI");
            var totalPrice = 0.00;
            var subTotal = 0.00;
            var shippingPrice = 0.00;
            var tax = 0.00;
            var amountPaid = 0.00;
            var discount = 0.00;
            for(var x in invli){
                totalPrice += parseFloat(invli[x].ERP7__Total_Price__c);
                tax += parseFloat(invli[x].ERP7__VAT_Amount__c);
                tax += parseFloat(invli[x].ERP7__Other_Tax__c);
                discount += parseFloat(invli[x].ERP7__Discount_Amount__c);
                subTotal += parseFloat(invli[x].ERP7__Sub_Total__c);
            }
            console.log('totalPrice : ',totalPrice);
            console.log('tax : ',tax);
            console.log('discount : ',discount);
            //added  changes by Saqlain Khan to store the discount amt so that it cal be used in another funtion 
            component.set("v.discountAmount",discount);
            console.log("The discount value set ", component.get("v.discountAmount"));
            component.set("v.taxAmount", tax);
            component.set("v.invLineSubTotal", subTotal);

            var couponDiscount = component.get('v.salesorder.ERP7__Coupon_Discount__c');
            if(couponDiscount!=null && couponDiscount!='' && couponDiscount!=undefined)discount += couponDiscount;
            if(couponDiscount == null || couponDiscount =='' || couponDiscount == undefined)couponDiscount = 0;
            var shipping_tax_ammount =0;
            if(component.get('v.enableShippingAmount') && component.get('v.enableShipping'))shipping_tax_ammount=component.get('v.salesorder.ERP7__Shipping_VAT__c');
            if(shipping_tax_ammount==null || shipping_tax_ammount=='')shipping_tax_ammount=0;
            if(component.get('v.enableShippingAmount') && component.get('v.enableShipping'))tax += shipping_tax_ammount;

            var renderedFields = component.find("inv_input_field");
            var shipping_amount = 0;
            shipping_amount=component.get('v.salesorder.ERP7__Total_Shipping_Amount__c');
            for(var  x in renderedFields){
                if(component.get('v.enableShippingAmount') && component.get('v.enableShipping')){
                    if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Shipping_Amount__c'){
                        renderedFields[x].set("v.value",shipping_amount);
                    }
                    if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Shipping_Amount__c'){
                        shippingPrice = renderedFields[x].get("v.value");

                    }
                }
                if(renderedFields[x].get('v.fieldName')==='ERP7__Amount_Paid__c'){
                    amountPaid = renderedFields[x].get("v.value");

                }

            }

            var downpayment = component.find("downPayment");
            var downpaymentAmt = component.find("downPaymentAmt");
            for(var  x in renderedFields){
                if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                    //renderedFields[x].set("v.value",parseFloat((shippingPrice + totalPrice + shipping_tax_ammount) - couponDiscount ));
                    if(component.get("v.selectedrecordTypeMap.DeveloperName") === 'Schedule_Invoice'){
                        renderedFields[x].set("v.value",parseFloat(((shippingPrice + totalPrice + shipping_tax_ammount) - couponDiscount ) - component.get('v.TDPayment')));
                    }else renderedFields[x].set("v.value",parseFloat(((shippingPrice + totalPrice + shipping_tax_ammount) - couponDiscount )));



                    //break;
                }
                if(renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c'){
                    renderedFields[x].set("v.value",parseFloat(tax));
                    //break;
                }
                if(renderedFields[x].get('v.fieldName')==='ERP7__Discount_Amount__c'){
                    renderedFields[x].set("v.value",parseFloat(discount));
                    //break;
                }
            }
        }catch(e){
            console.log('err',e);
        }
    },

    getFieldsSetApiNameHandler : function(component,objectApiName,fieldSetApiName){
        var action = component.get("c.getFieldsSetApiName");
        action.setParams({
            sObjectName : objectApiName,
            fieldSetApiName :fieldSetApiName
        });
        action.setCallback(this,function(response){
            if(objectApiName==='ERP7__Invoice__c')
                component.set("v.invoiceFields",response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
   
   /* 
    fetchTotalDownPayment : function(cmp){

        var action = cmp.get("c.fetchTotalDownPayment1");
        action.setParams({
            orderId:cmp.get("v.SO_Id"),
            SorderId:cmp.get("v.Std_Id")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                cmp.set('v.TDPayment', response.getReturnValue());
                console.log('fetchTotalDownPayment1 TDPayment :  ',cmp.get('v.TDPayment'));
            }
            else{
                console.log('Error:',response.getError());
            }
        });
        $A.enqueueAction(action);
    },
*/
    
    // Added by Saqlain to Ensures it always has 2 decimal places.
     fetchTotalDownPayment : function(cmp) {
        var action = cmp.get("c.fetchTotalDownPayment1");
        action.setParams({
            orderId: cmp.get("v.SO_Id"),
            SorderId: cmp.get("v.Std_Id"),
            sordiname : 'just checking'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();

                if (result != null) {
                    result = parseFloat(result).toFixed(2);
                }

                cmp.set("v.TDPayment", result);
                console.log("fetchTotalDownPayment1 TDPayment:", cmp.get("v.TDPayment"));
            } else {
                console.error(" Error:", response.getError());
            }
        });
        $A.enqueueAction(action);
    },


    fetchScheduleInvoices : function(cmp){
        var action = cmp.get("c.scheduleInvoices");
        action.setParams({
            orderId:cmp.get("v.SO_Id"),
            SorderId:cmp.get("v.Std_Id")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                console.log('response scheduleInvoices : ',response.getReturnValue());
                cmp.set('v.schInvoiceList', response.getReturnValue().schlst);
                cmp.set('v.advanceInvoiceList', response.getReturnValue().advlst);
                var advanceInvoices = [];
                console.log('advanceInvoices : ',response.getReturnValue().advlst);
                console.log('Length of Advance : ',advanceInvoices);

                advanceInvoices = response.getReturnValue().advlst;
                var advancePaymentPaidAmount = 0.0;
                for(var x in advanceInvoices){
                    if(advanceInvoices[x].ERP7__Amount_Paid__c != null && advanceInvoices[x].ERP7__Amount_Paid__c != undefined){
                        advancePaymentPaidAmount = advancePaymentPaidAmount + advanceInvoices[x].ERP7__Amount_Paid__c;
                    }
                }
                console.log('advancePaymentPaidAmount : ',advancePaymentPaidAmount);
                cmp.set('v.advancePaymentPaidAmount',advancePaymentPaidAmount);
                var schInvoices = [];
                schInvoices = response.getReturnValue().schlst;
                var priorIA = 0.00;
                var priorIAPaidApplied = 0.00;
                var priorIAPaidReturned = 0.00;
                var priorSalesPaidApplied = 0.00;
                var creditIA = 0.00;
                var salesorderAmount = 0.00;
                var AmountPaid = 0.00;
                var salesInvoices = [];
                salesInvoices = response.getReturnValue().saleslst;
                for(var i in salesInvoices){
                    if(salesInvoices[i].ERP7__Paid_Amount_Applied__c!=null) priorSalesPaidApplied = parseFloat(salesInvoices[i].ERP7__Paid_Amount_Applied__c) +  priorSalesPaidApplied;
                    if(salesInvoices[i].ERP7__Paid_Amount_Returned__c!=null) priorIAPaidReturned = parseFloat(salesInvoices[i].ERP7__Paid_Amount_Returned__c) +  priorIAPaidReturned;
                }
                for(var i in schInvoices){
                    if(schInvoices[i].ERP7__Invoice_Amount__c!=null) priorIA = parseFloat(schInvoices[i].ERP7__Invoice_Amount__c) +  priorIA;
                    if(schInvoices[i].ERP7__Credit_Note__c!=null) creditIA = parseFloat(schInvoices[i].ERP7__Credit_Note__c) +  creditIA;
                    salesorderAmount = parseFloat(schInvoices[i].ERP7__Sales_Order_Amount__c);
                    if(schInvoices[i].ERP7__Paid_Amount_Applied__c!=null) priorIAPaidApplied = parseFloat(schInvoices[i].ERP7__Paid_Amount_Applied__c) +  priorIAPaidApplied;
                    if(schInvoices[i].ERP7__Paid_Amount_Returned__c!=null) priorIAPaidReturned = parseFloat(schInvoices[i].ERP7__Paid_Amount_Returned__c) +  priorIAPaidReturned;
                }
            /*    cmp.set("v.schInvAmount", priorIA);
                cmp.set("v.schInvCreditAmount", creditIA);
                cmp.set("v.schInvPaidApplied", priorIAPaidApplied);
                cmp.set("v.PaidAmountApplied", cmp.get("v.AmountPaid")-priorIAPaidApplied-priorSalesPaidApplied+priorIAPaidReturned);
                 console.log('AmountPaid: ', cmp.get("v.AmountPaid"));
                console.log('priorIAPaidApplied: ', priorIAPaidApplied);
                console.log('priorSalesPaidApplied: ', priorSalesPaidApplied);
                console.log('priorIAPaidReturned: ', priorIAPaidReturned);
                cmp.set("v.TotalPaidAmountApplied", priorIAPaidApplied+priorSalesPaidApplied-priorIAPaidReturned);
                console.log('PaidAmountApplied 1: ',cmp.get("v.PaidAmountApplied"));
                var paidAmountApplied = cmp.find("paidAmountApplied");
                if(paidAmountApplied!=null && paidAmountApplied!=undefined && paidAmountApplied!='') paidAmountApplied.set("v.value",cmp.get("v.PaidAmountApplied"));
                //if(val!=null && val!=undefined && val!=''){
                var renderedFields = cmp.find("inv_input_field");
                for(var  x in renderedFields){
                  if(advanceInvoices.length > 0){
                    if(renderedFields[x].get('v.fieldName')==='ERP7__Paid_Amount_Applied__c'){
                      renderedFields[x].set('v.value',cmp.get("v.PaidAmountApplied"));
                    }
                  }
                }
                //}  */
                //
                
                cmp.set("v.schInvAmount", priorIA);
                cmp.set("v.schInvCreditAmount", creditIA);
              //  cmp.set("v.schInvPaidApplied", priorIAPaidApplied);
                
                // 💰 Calculate PaidAmountApplied
                 var schInvoiceList = cmp.get('v.schInvoiceList') || [];
                var advanceInvoiceList = cmp.get('v.advanceInvoiceList') || [];
            
                var schCount = Array.isArray(schInvoiceList) ? schInvoiceList.length : 0;
                var advCount = Array.isArray(advanceInvoiceList) ? advanceInvoiceList.length : 0;
            
                console.log('The schInvoiceList value', JSON.stringify(schInvoiceList));
                console.log('The advanceInvoiceList value', JSON.stringify(advanceInvoiceList));
                console.log('schCount:', schCount, 'advCount:', advCount, 'IF? ->', (schCount > 0 && advCount === 0));
            
                // ✅ IF: at least one schedule invoice and NO advance invoices
    if ((cmp.get("v.selectedrecordTypeMap.DeveloperName")==='Schedule_Invoice' || schCount > 0) && advCount === 0) {
                    console.log('Condition met: ≥1 schInvoice and no advanceInvoice');
                    //Not setting the Pid amt applied because its only the schedule invoice.
                     cmp.set(
                    "v.PaidAmountApplied", 0);
                    
                    cmp.set("v.schInvPaidApplied", 0);
                    
                }
                else{
                    cmp.set("v.schInvPaidApplied", priorIAPaidApplied);
                      cmp.set(
                    "v.PaidAmountApplied",
                    cmp.get("v.AmountPaid") - priorIAPaidApplied - priorSalesPaidApplied + priorIAPaidReturned
                );
                }
              
                
                // 🧾 Detailed Logs for Debugging
                 
                
                console.log('=== Schedule Invoice Calculations ===');
                console.log('v.PaidAmountApplied:', cmp.get("v.PaidAmountApplied"));                
                console.log('v.AmountPaid:', cmp.get("v.AmountPaid"));
                console.log('v.schInvAmount (priorIA):', priorIA);
                console.log('v.schInvCreditAmount (creditIA):', creditIA);
                console.log('v.schInvPaidApplied (priorIAPaidApplied):', priorIAPaidApplied);
                console.log('priorSalesPaidApplied:', priorSalesPaidApplied);
                console.log('priorIAPaidReturned:', priorIAPaidReturned);
                console.log('Calculated v.PaidAmountApplied:', cmp.get("v.PaidAmountApplied"));
                
                // 🧮 Total Paid Amount Applied
                cmp.set(
                    "v.TotalPaidAmountApplied",
                    priorIAPaidApplied + priorSalesPaidApplied - priorIAPaidReturned
                );
                
                // 🧩 Log computed totals
                console.log('v.TotalPaidAmountApplied:', cmp.get("v.TotalPaidAmountApplied"));
                console.log('=====================================');
                
                // 🧱 Update UI Field for PaidAmountApplied
                var paidAmountApplied = cmp.find("paidAmountApplied");
                if (paidAmountApplied) {
                    paidAmountApplied.set("v.value", cmp.get("v.PaidAmountApplied"));
                    console.log('paidAmountApplied input updated with:', cmp.get("v.PaidAmountApplied"));
                } else {
                    console.warn('⚠️ paidAmountApplied field not found');
                }
                
                // 🧾 Update rendered fields if advance invoices exist
                var renderedFields = cmp.find("inv_input_field");
                for (var x in renderedFields) {
                    if (advanceInvoices.length > 0) {
                        if (renderedFields[x].get('v.fieldName') === 'ERP7__Paid_Amount_Applied__c') {
                            renderedFields[x].set('v.value', cmp.get("v.PaidAmountApplied"));
                            console.log('Rendered field ERP7__Paid_Amount_Applied__c updated with:', cmp.get("v.PaidAmountApplied"));
                        }
                    }
                }

                var amt = priorIA-creditIA;
                console.log('amt : ',amt);
                console.log('salesorderAmount : ',salesorderAmount);

                if(amt>=salesorderAmount && schInvoices.length>0){
                    console.log('in : ');
                    cmp.set("v.selectedrecordTypeMap.DeveloperName",'');
                    cmp.set("v.showToast",true);
                    //this.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','We have already record a complete scheduled invoices for this Order');
                    cmp.set("v.message","We have already record a complete scheduled invoices for this Order");
                    window.setTimeout(
                        $A.getCallback(function() {
                            history.back();
                        }), 5000
                    );
                }
                if(schInvoices.length>0 && cmp.get("v.selectedrecordTypeMap.DeveloperName")=='Advance'){
                    cmp.set("v.showToast",true);
                    cmp.set("v.message","There is already a schedule invoice against this order. So please create the schedule invoice");
                    cmp.set("v.selectedrecordTypeMap.DeveloperName", '');
                }
                console.log('cmp.get("v.AmountPaid") : ',cmp.get("v.AmountPaid"));
                console.log('TDPayment get : ',cmp.get("v.TDPayment"));
                              var TDPayment = cmp.get("v.TDPayment");
                TDPayment = parseFloat(TDPayment).toFixed(2);
                cmp.set("v.TDPayment", TDPayment);
                console.log('TDPayment get after converting to 2fixed : ',cmp.get("v.TDPayment"));

                console.log('cmp.get("v.selectedrecordTypeMap").DeveloperName : ',cmp.get("v.selectedrecordTypeMap").DeveloperName);
                if(cmp.get("v.TDPayment")!=null && cmp.get("v.TDPayment")!=undefined && cmp.get("v.TDPayment")>0 && cmp.get("v.TDPayment") > cmp.get("v.AmountPaid") && (cmp.get("v.selectedrecordTypeMap").DeveloperName === 'Schedule_Invoice' || cmp.get("v.selectedrecordTypeMap").DeveloperName === 'Sale')){ //Moin Commented this added cmp.get("v.TDPayment") != cmp.get("v.AmountPaid")// cmp.get("v.TDPayment") != cmp.get("v.AmountPaid") has been changed to equals as requested by polymem. The user should be able to create schedule invoice once the advance invovice is paid and the total down payemnt equals Amount paid
                    cmp.set("v.showToast",true);
                    cmp.set("v.message","There is already an Advance invoice against this order which is not paid. So please create a payment and record a schedule invoice");
                    cmp.set("v.selectedrecordTypeMap.DeveloperName", '');
                }
            }
            else{
                console.log('Error:',response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    /*checkMultipleCurrency : function(cmp){
        var action = cmp.get("c.checkMultipleCurrency");
        action.setCallback(this,function(response){
            cmp.set('v.MultipleCurrency',response.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    fetchCurrencyIso : function(cmp){
        var action = cmp.get("c.currencyIso");
        action.setParams({SalesorderId:cmp.get("v.SO_Id")});
        action.setCallback(this,function(response){
            cmp.set('v.CurrencyIsoCode',response.getReturnValue());
        });
    },*/

    fetchOrderInfo : function(cmp){

        var action = cmp.get("c.fetchOrderDetails");
        action.setParams({
            orderId:cmp.get("v.SO_Id")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                cmp.set('v.salesorder',response.getReturnValue());
                cmp.set("v.orderAmount", response.getReturnValue().ERP7__Sales_Order_Amount__c);
                if(cmp.get('v.salesorder.ERP7__Total_Shipping_Amount__c') == null ||  cmp.get('v.salesorder.ERP7__Total_Shipping_Amount__c') == '')
                    cmp.set('v.salesorder.ERP7__Total_Shipping_Amount__c',0);
                if(cmp.get('v.salesorder.ERP7__Shipping_VAT__c') == null ||  cmp.get('v.salesorder.ERP7__Shipping_VAT__c') == '')
                    cmp.set('v.salesorder.ERP7__Shipping_VAT__c',0);
                if(cmp.get('v.salesorder.ERP7__Include_Shipping_Amount__c'))cmp.set('v.enableShippingAmount',false);
                else cmp.set('v.enableShippingAmount',true);
                var invli = cmp.get("v.INVLIList");
                var totalPrice = 0.00;
                var tax = 0.00;
                for(var x in invli){
                    totalPrice += invli[x].ERP7__Sub_Total__c;
                    tax += invli[x].ERP7__VAT_Amount__c;
                    tax += invli[x].ERP7__Other_Tax__c;
                }
                var result = response.getReturnValue();
                cmp.set("v.NewInvoice.ERP7__Organisation__c", result.ERP7__Organisation__c);
                cmp.set("v.NewInvoice.ERP7__Account__c", result.ERP7__Account__c);
                cmp.set("v.NewInvoice.ERP7__Contact__c", result.ERP7__Contact__c);
                var obj = {'ERP7__Organisation__c':result.ERP7__Organisation__c,'ERP7__Account__c':result.ERP7__Account__c,'ERP7__Contact__c':result.ERP7__Contact__c,
                           'ERP7__Amount_Paid__c':result.ERP7__Amount_Paid__c,'ERP7__Total_Down_Payment_Amount__c':cmp.get('v.TDPayment'),'ERP7__Sales_Invoice_Percentage__c':0, 'ERP7__Sales_Invoice_Tax_Percentage__c':0
                          };
                /* var obj = {'ERP7__Organisation__c':result.ERP7__Organisation__c,'ERP7__Account__c':result.ERP7__Account__c,
                           'ERP7__Invoice_Shipping_Amount__c':result.ERP7__Total_Shipping_Amount__c,
                           'ERP7__Tax_Amount__c':parseFloat(tax), //response.getReturnValue().ERP7__Total_Tax_Amount__c,
                           'ERP7__Amount_Paid__c':result.ERP7__Amount_Paid__c,
                           'ERP7__Invoice_Amount__c':parseFloat((tax+totalPrice+result.ERP7__Total_Shipping_Amount__c) - result.ERP7__Amount_Paid__c) //response.getReturnValue().ERP7__Sales_Order_Amount__c
                          };*/
                /*
                           'ERP7__Total_Down_Payment_Amount__c':parseFloat(tax+totalPrice+result.ERP7__Total_Shipping_Amount__c),
                           'ERP7__Down_Payment__c':parseFloat(1.00),*/
                if(result.ERP7__Amount_Paid__c!=null && result.ERP7__Amount_Paid__c>0){
                    cmp.set("v.displayPaid", true);
                }
                if(result.ERP7__Account__c!=null && result.ERP7__Account__r.ERP7__Payment_Terms__c!=null){
                    var now =  new Date();
                    now.setDate(now.getDate() + result.ERP7__Account__r.ERP7__Payment_Terms__c);
                    cmp.set("v.defaultValues",{'ERP7__Invoice_Date__c':now.getFullYear()+'-'+(now.getMonth()+1)+'-'+now.getDate(), 'ERP7__Invoice_Due_Date__c':now.getFullYear()+'-'+(now.getMonth()+1)+'-'+now.getDate()});
                }
                cmp.set("v.AmountPaid", parseFloat(result.ERP7__Amount_Paid__c));
                if(cmp.get("v.selectedrecordTypeMap").DeveloperName === 'Schedule_Invoice'){
                    var downPaymentAmtSales = cmp.find("downPaymentAmtSales");
                    downPaymentAmtSales.set("v.value",0.00);
                    var downPaymentTax = cmp.find("downPaymentTax");
                    if(downPaymentTax!=undefined) downPaymentTax.set("v.value",0.00);
                }
                if(cmp.get("v.selectedrecordTypeMap").DeveloperName === 'Advance'){
                    var downpayment = cmp.find("downPayment");
                    //downpayment.set("v.value",1);
                    downpayment.set("v.disabled",false);

                    // Disabling downpayment for first time
                    var downpaymentAmt = cmp.find("downPaymentAmt");
                    /* downpaymentAmt.set("v.value",parseFloat(tax+totalPrice+result.ERP7__Total_Shipping_Amount__c));
                   */
                    downpaymentAmt.set("v.disabled",false);
                    /*obj['ERP7__Down_Payment__c'] = 1;
                    obj['ERP7__Total_Down_Payment_Amount__c'] = parseFloat(tax+totalPrice+result.ERP7__Total_Shipping_Amount__c);
                    */
                }
                if(!$A.util.isUndefinedOrNull(obj)){
                    var renderedFields = cmp.find("inv_input_field");
                    for(var  x in renderedFields){

                        if(obj.hasOwnProperty(renderedFields[x].get('v.fieldName')))
                            renderedFields[x].set("v.value",obj[renderedFields[x].get('v.fieldName')]);

                    }
                }
            }else{
                console.log('Error:',response.getError());
            }
        });
        if(!$A.util.isEmpty(cmp.get("v.SO_Id")))
            $A.enqueueAction(action);
        else
            this.setDefaulthandler(cmp);

    },
    fetchMultiOrderInfo: function (cmp) {
        console.log('fetchMultiOrderInfo');
        var action = cmp.get("c.fetchMultiOrderDetails");
        action.setParams({
            orderIds: cmp.get("v.SalOrdIdsList")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                //cmp.set('v.salesorder',response.getReturnValue());

                var OrderAmount = 0.00;
                var ShippingAmount = 0.00;
                var AmountPaid = 0.00;
                var NameList = [];
                for (var x in result) {
                    OrderAmount += result[x].ERP7__Sales_Order_Amount__c;
                    AmountPaid += result[x].ERP7__Amount_Paid__c;
                    NameList.push(result[x].Name);
                }
                cmp.set("v.OrdNameList", NameList)
                cmp.set("v.orderAmount", OrderAmount);
                // if(cmp.get('v.salesorder.ERP7__Total_Shipping_Amount__c') == null ||  cmp.get('v.salesorder.ERP7__Total_Shipping_Amount__c') == '')
                //     cmp.set('v.salesorder.ERP7__Total_Shipping_Amount__c',0);
                // if(cmp.get('v.salesorder.ERP7__Shipping_VAT__c') == null ||  cmp.get('v.salesorder.ERP7__Shipping_VAT__c') == '')
                //     cmp.set('v.salesorder.ERP7__Shipping_VAT__c',0);
                // if(cmp.get('v.salesorder.ERP7__Include_Shipping_Amount__c'))cmp.set('v.enableShippingAmount',false);
                // else cmp.set('v.enableShippingAmount',true);
                var invli = cmp.get("v.INVLIList");
                var totalPrice = 0.00;
                var tax = 0.00;
                for (var x in invli) {
                    totalPrice += invli[x].ERP7__Sub_Total__c;
                    tax += invli[x].ERP7__VAT_Amount__c;
                    tax += invli[x].ERP7__Other_Tax__c;
                }
                var OrdResult = result[0];
                cmp.set("v.NewInvoice.ERP7__Organisation__c", OrdResult.ERP7__Organisation__c);
                cmp.set("v.NewInvoice.ERP7__Account__c", OrdResult.ERP7__Account__c);
                cmp.set("v.NewInvoice.ERP7__Contact__c", OrdResult.ERP7__Contact__c);
                var obj = {
                    'ERP7__Organisation__c': OrdResult.ERP7__Organisation__c, 'ERP7__Account__c': OrdResult.ERP7__Account__c, 'ERP7__Contact__c': OrdResult.ERP7__Contact__c,
                    'ERP7__Amount_Paid__c': AmountPaid, 'ERP7__Total_Down_Payment_Amount__c': cmp.get('v.TDPayment'), 'ERP7__Sales_Invoice_Percentage__c': 0, 'ERP7__Sales_Invoice_Tax_Percentage__c': 0
                };
                /* var obj = {'ERP7__Organisation__c':result.ERP7__Organisation__c,'ERP7__Account__c':result.ERP7__Account__c,
                           'ERP7__Invoice_Shipping_Amount__c':result.ERP7__Total_Shipping_Amount__c,
                           'ERP7__Tax_Amount__c':parseFloat(tax), //response.getReturnValue().ERP7__Total_Tax_Amount__c,
                           'ERP7__Amount_Paid__c':result.ERP7__Amount_Paid__c,
                           'ERP7__Invoice_Amount__c':parseFloat((tax+totalPrice+result.ERP7__Total_Shipping_Amount__c) - result.ERP7__Amount_Paid__c) //response.getReturnValue().ERP7__Sales_Order_Amount__c
                          };*/
                /*
                           'ERP7__Total_Down_Payment_Amount__c':parseFloat(tax+totalPrice+result.ERP7__Total_Shipping_Amount__c),
                           'ERP7__Down_Payment__c':parseFloat(1.00),*/
                if (AmountPaid != null && AmountPaid > 0) {
                    cmp.set("v.displayPaid", true);
                }
                if (OrdResult.ERP7__Account__c != null && OrdResult.ERP7__Account__r.ERP7__Payment_Terms__c != null) {
                    var now = new Date();
                    now.setDate(now.getDate() + OrdResult.ERP7__Account__r.ERP7__Payment_Terms__c);
                    cmp.set("v.defaultValues", { 'ERP7__Invoice_Date__c': now.getFullYear() + '-' + (now.getMonth() + 1) + '-' + now.getDate(), 'ERP7__Invoice_Due_Date__c': now.getFullYear() + '-' + (now.getMonth() + 1) + '-' + now.getDate() });
                }
                cmp.set("v.AmountPaid", parseFloat(AmountPaid));
                if (cmp.get("v.selectedrecordTypeMap").DeveloperName === 'Schedule_Invoice') {
                    var downPaymentAmtSales = cmp.find("downPaymentAmtSales");
                    downPaymentAmtSales.set("v.value", 0.00);
                    var downPaymentTax = cmp.find("downPaymentTax");
                    if (downPaymentTax != undefined) downPaymentTax.set("v.value", 0.00);
                }
                if (cmp.get("v.selectedrecordTypeMap").DeveloperName === 'Advance') {
                    var downpayment = cmp.find("downPayment");
                    //downpayment.set("v.value",1);
                    downpayment.set("v.disabled", false);

                    // Disabling downpayment for first time
                    var downpaymentAmt = cmp.find("downPaymentAmt");
                    /* downpaymentAmt.set("v.value",parseFloat(tax+totalPrice+result.ERP7__Total_Shipping_Amount__c));
                   */
                    downpaymentAmt.set("v.disabled", false);
                    /*obj['ERP7__Down_Payment__c'] = 1;
                    obj['ERP7__Total_Down_Payment_Amount__c'] = parseFloat(tax+totalPrice+result.ERP7__Total_Shipping_Amount__c);
                    */
                }
                if (!$A.util.isUndefinedOrNull(obj)) {
                    var renderedFields = cmp.find("inv_input_field");
                    for (var x in renderedFields) {

                        if (obj.hasOwnProperty(renderedFields[x].get('v.fieldName')))
                            renderedFields[x].set("v.value", obj[renderedFields[x].get('v.fieldName')]);

                    }
                }
            } else {
                console.log('Error:', response.getError());
            }
        });
        if (cmp.get("v.SalOrdIdsList").length > 0)
            $A.enqueueAction(action);
        else
            this.setDefaulthandler(cmp);

    },
    fetchStnOrderInfo : function(cmp){
        var action = cmp.get("c.fetchStndOrdDetails");
        action.setParams({
            Std_Id:cmp.get("v.Std_Id")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                cmp.set('v.salesorder',response.getReturnValue());
                console.log('response fetchStndOrdDetails : ',response.getReturnValue());
                cmp.set("v.orderAmount", response.getReturnValue().ERP7__Order_Amount__c);
                if(cmp.get('v.salesorder.ERP7__Total_Shipping_Amount__c') == null ||  cmp.get('v.salesorder.ERP7__Total_Shipping_Amount__c') == '')
                    cmp.set('v.salesorder.ERP7__Total_Shipping_Amount__c',0);
                if(cmp.get('v.salesorder.ERP7__Shipping_VAT__c') == null ||  cmp.get('v.salesorder.ERP7__Shipping_VAT__c') == '')
                    cmp.set('v.salesorder.ERP7__Shipping_VAT__c',0);
                if(cmp.get('v.salesorder.ERP7__Include_Shipping_Amount__c'))cmp.set('v.enableShippingAmount',false);
                else cmp.set('v.enableShippingAmount',true);
                var invli = cmp.get("v.INVLIList");
                var totalPrice = 0.00;
                var tax = 0.00;
                var VATamt = 0.00;
                for(var x in invli){
                    totalPrice += invli[x].ERP7__Sub_Total__c;
                    tax += invli[x].ERP7__VAT_Amount__c;
                    VATamt += invli[x].ERP7__VAT_Amount__c;
                    tax += invli[x].ERP7__Other_Tax__c;
                }
                //var ordamt = (cmp.get("v.orderAmount") != undefined && cmp.get("v.orderAmount") != null && cmp.get("v.orderAmount") != '') ? cmp.get("v.orderAmount") : 0;
                //cmp.set("v.orderAmount", parseFloat(ordamt+VATamt));
                var result = response.getReturnValue();
                console.log('result fetchStndOrdDetails',JSON.stringify(result));
                cmp.set("v.NewInvoice.ERP7__Organisation__c", result.ERP7__Organisation__c);
                //cmp.set("v.NewInvoice.ERP7__Account__c", result.ERP7__Account__c); line 467 commented By parveez on 23-Aug-2023 and added new line on 468.
                cmp.set("v.NewInvoice.ERP7__Account__c", result.AccountId);
                cmp.set("v.NewInvoice.ERP7__Contact__c", result.ERP7__Contact__c);
                var obj = {'ERP7__Organisation__c':result.ERP7__Organisation__c,'ERP7__Account__c':result.AccountId,'ERP7__Contact__c':result.ERP7__Contact__c,
                           'ERP7__Amount_Paid__c':result.ERP7__Amount_Paid__c,'ERP7__Total_Down_Payment_Amount__c':cmp.get('v.TDPayment'),'ERP7__Sales_Invoice_Percentage__c':0, 'ERP7__Sales_Invoice_Tax_Percentage__c':0
                          };
                var resultAmountPaid = 0;

                try{
                    console.log('result.ERP7__Amount_Paid__c~>'+result.ERP7__Amount_Paid__c);
                    if($A.util.isUndefinedOrNull(result.ERP7__Amount_Paid__c) || $A.util.isEmpty(result.ERP7__Amount_Paid__c)){
                        resultAmountPaid = 0;
                    }else resultAmountPaid = result.ERP7__Amount_Paid__c;
                    console.log('resultAmountPaid~>'+resultAmountPaid);
                }catch(e){
                    console.log('err',e);
                }
                resultAmountPaid = (resultAmountPaid > 0) ? parseFloat(resultAmountPaid) : 0;
                cmp.set("v.AmountPaid", resultAmountPaid);
                console.log('v.AmountPaid~> 123   --> '+cmp.get("v.AmountPaid"));
                console.log('just checking ');

                if(resultAmountPaid > 0){
                    cmp.set("v.displayPaid", true);
                 console.log('advancePaymentPaidAmount: ',cmp.get("v.advancePaymentPaidAmount"));
                  
 
                    
                }
                
                console.log('just checking  outside the loop');
                if(result.AccountId!=null && result.Account.ERP7__Payment_Terms__c!=null){
                    var now =  new Date();
                    now.setDate(now.getDate() + result.Account.ERP7__Payment_Terms__c);
                    cmp.set("v.defaultValues",{'ERP7__Invoice_Date__c':now.getFullYear()+'-'+(now.getMonth()+1)+'-'+now.getDate(), 'ERP7__Invoice_Due_Date__c':now.getFullYear()+'-'+(now.getMonth()+1)+'-'+now.getDate()});
                }
                if(cmp.get("v.selectedrecordTypeMap").DeveloperName === 'Schedule_Invoice'){
                    var downPaymentAmtSales = cmp.find("downPaymentAmtSales");
                    if(downPaymentAmtSales != undefined) downPaymentAmtSales.set("v.value",0.00);
                    var downPaymentTax = cmp.find("downPaymentTax");
                    if(downPaymentTax!=undefined) downPaymentTax.set("v.value",0.00);
                }
                if(cmp.get("v.selectedrecordTypeMap").DeveloperName === 'Advance'){
                    var downpayment = cmp.find("downPayment");
                    //downpayment.set("v.value",1);
                    if(downpayment != undefined)   downpayment.set("v.disabled",false);

                    // Disabling downpayment for first time
                    var downpaymentAmt = cmp.find("downPaymentAmt");

                    if(downpaymentAmt != undefined) downpaymentAmt.set("v.disabled",false);

                }
                if(!$A.util.isUndefinedOrNull(obj)){
                    var renderedFields = cmp.find("inv_input_field");
                    for(var  x in renderedFields){
                        if(obj.hasOwnProperty(renderedFields[x].get('v.fieldName')))
                            renderedFields[x].set("v.value",obj[renderedFields[x].get('v.fieldName')]);

                    }
                }
            }else{
                console.log('Error:',response.getError());
            }
        });
        if(!$A.util.isEmpty(cmp.get("v.Std_Id")))
            $A.enqueueAction(action);
        else
            this.setDefaulthandler(cmp);

    },

    fetchMultiStnOrderInfo: function (cmp) {
        console.log('fetchMultiStnOrderInfo');
        var action = cmp.get("c.fetchMultiStndOrdDetails");
        action.setParams({
            Std_Ids: cmp.get("v.OrdIdsList")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                //cmp.set('v.salesorder',response.getReturnValue());
                var result = response.getReturnValue();
                var OrderAmount = 0.00;
                var ShippingAmount = 0.00;
                var AmountPaid = 0.00;
                var NameList = [];
                for (var x in result) {
                    OrderAmount += result[x].ERP7__Order_Amount__c;
                    AmountPaid += result[x].ERP7__Amount_Paid__c;
                    NameList.push(result[x].Name);
                }
                cmp.set("v.OrdNameList", NameList)
                cmp.set("v.orderAmount", OrderAmount);
                // if (cmp.get('v.salesorder.ERP7__Total_Shipping_Amount__c') == null || cmp.get('v.salesorder.ERP7__Total_Shipping_Amount__c') == '')
                //     cmp.set('v.salesorder.ERP7__Total_Shipping_Amount__c', 0);
                // if (cmp.get('v.salesorder.ERP7__Shipping_VAT__c') == null || cmp.get('v.salesorder.ERP7__Shipping_VAT__c') == '')
                //     cmp.set('v.salesorder.ERP7__Shipping_VAT__c', 0);
                // if (cmp.get('v.salesorder.ERP7__Include_Shipping_Amount__c')) cmp.set('v.enableShippingAmount', false);
                // else cmp.set('v.enableShippingAmount', true);
                var invli = cmp.get("v.INVLIList");
                var totalPrice = 0.00;
                var tax = 0.00;
                var VATamt = 0.00;
                for (var x in invli) {
                    totalPrice += invli[x].ERP7__Sub_Total__c;
                    tax += invli[x].ERP7__VAT_Amount__c;
                    VATamt += invli[x].ERP7__VAT_Amount__c;
                    tax += invli[x].ERP7__Other_Tax__c;
                }
                //var ordamt = (cmp.get("v.orderAmount") != undefined && cmp.get("v.orderAmount") != null && cmp.get("v.orderAmount") != '') ? cmp.get("v.orderAmount") : 0;
                //cmp.set("v.orderAmount", parseFloat(ordamt+VATamt));
                var OrdResult = result[0];
                console.log('result fetchStndOrdDetails', JSON.stringify(result));
                cmp.set("v.NewInvoice.ERP7__Organisation__c", OrdResult.ERP7__Organisation__c);
                //cmp.set("v.NewInvoice.ERP7__Account__c", result.ERP7__Account__c); line 467 commented By parveez on 23-Aug-2023 and added new line on 468.
                cmp.set("v.NewInvoice.ERP7__Account__c", OrdResult.AccountId);
                cmp.set("v.NewInvoice.ERP7__Contact__c", OrdResult.ERP7__Contact__c);
                var obj = {
                    'ERP7__Organisation__c': OrdResult.ERP7__Organisation__c, 'ERP7__Account__c': OrdResult.AccountId, 'ERP7__Contact__c': OrdResult.ERP7__Contact__c,
                    'ERP7__Amount_Paid__c': AmountPaid, 'ERP7__Total_Down_Payment_Amount__c': cmp.get('v.TDPayment'), 'ERP7__Sales_Invoice_Percentage__c': 0, 'ERP7__Sales_Invoice_Tax_Percentage__c': 0
                };
                var resultAmountPaid = 0;

                try {
                    console.log('result.ERP7__Amount_Paid__c~>' + AmountPaid);
                    if ($A.util.isUndefinedOrNull(AmountPaid) || $A.util.isEmpty(AmountPaid)) {
                        resultAmountPaid = 0;
                    } else resultAmountPaid = AmountPaid;
                    console.log('resultAmountPaid~>' + resultAmountPaid);
                } catch (e) {
                    console.log('err', e);
                }
                resultAmountPaid = (resultAmountPaid > 0) ? parseFloat(resultAmountPaid) : 0;
                cmp.set("v.AmountPaid", resultAmountPaid);
                console.log('v.AmountPaid~>' + cmp.get("v.AmountPaid"));
                if (resultAmountPaid > 0) {
                    cmp.set("v.displayPaid", true);
                }
                if (OrdResult.AccountId != null && OrdResult.Account.ERP7__Payment_Terms__c != null) {
                    var now = new Date();
                    now.setDate(now.getDate() + OrdResult.Account.ERP7__Payment_Terms__c);
                    cmp.set("v.defaultValues", { 'ERP7__Invoice_Date__c': now.getFullYear() + '-' + (now.getMonth() + 1) + '-' + now.getDate(), 'ERP7__Invoice_Due_Date__c': now.getFullYear() + '-' + (now.getMonth() + 1) + '-' + now.getDate() });
                }
                if (cmp.get("v.selectedrecordTypeMap").DeveloperName === 'Schedule_Invoice') {
                    var downPaymentAmtSales = cmp.find("downPaymentAmtSales");
                    if (downPaymentAmtSales != undefined) downPaymentAmtSales.set("v.value", 0.00);
                    var downPaymentTax = cmp.find("downPaymentTax");
                    if (downPaymentTax != undefined) downPaymentTax.set("v.value", 0.00);
                }
                if (cmp.get("v.selectedrecordTypeMap").DeveloperName === 'Advance') {
                    var downpayment = cmp.find("downPayment");
                    //downpayment.set("v.value",1);
                    if (downpayment != undefined) downpayment.set("v.disabled", false);

                    // Disabling downpayment for first time
                    var downpaymentAmt = cmp.find("downPaymentAmt");

                    if (downpaymentAmt != undefined) downpaymentAmt.set("v.disabled", false);

                }
                if (!$A.util.isUndefinedOrNull(obj)) {
                    var renderedFields = cmp.find("inv_input_field");
                    for (var x in renderedFields) {
                        if (obj.hasOwnProperty(renderedFields[x].get('v.fieldName')))
                            renderedFields[x].set("v.value", obj[renderedFields[x].get('v.fieldName')]);

                    }
                }
            } else {
                console.log('Error:', response.getError());
            }
        });
        if (cmp.get("v.OrdIdsList").length > 0)
            $A.enqueueAction(action);
        else
            this.setDefaulthandler(cmp);

    },

    getInvoiceLineItem:function(component){

        var action = component.get("c.getInvoiceLineItems2");
        action.setParams({
            SOId : component.get("v.SO_Id"),
            Std_Id : component.get("v.Std_Id")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                console.log('response getInvoiceLineItems : ',response.getReturnValue());
                component.set("v.INVLIList",response.getReturnValue());
            }else{
                console.log('Error:',response.getError());
            }

        });
        if(!$A.util.isEmpty(component.get("v.SO_Id")) || !$A.util.isEmpty(component.get("v.Std_Id")))
            $A.enqueueAction(action);

        else
            component.set("v.INVLIList",[]);

    },
    getInvoiceLineItems: function (component) {
        console.log('getMultiInvoiceLineItems');
        var action = component.get("c.getMultiInvoiceLineItems");
        action.setParams({
            SOIds: component.get("v.SalOrdIdsList").length > 0 ? component.get("v.SalOrdIdsList") : [],
            Std_Ids: component.get("v.OrdIdsList").length > 0 ? component.get("v.OrdIdsList") : []
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('response getInvoiceLineItems : ', response.getReturnValue());
                component.set("v.INVLIList", response.getReturnValue());
            } else {
                console.log('Error:', response.getError());
            }

        });
        $A.enqueueAction(action);



    },
    setDefaulthandler:function(component){
        var obj = component.get("v.defaultValues");
        var now =  new Date();
        component.set('v.today',now.getFullYear()+'-'+(now.getMonth()+1)+'-'+now.getDate());
        var renderedFields = component.find("inv_input_field");
        var downpayment = component.find("downPayment");
        if(!$A.util.isUndefined(downpayment)){
            downpayment.set("v.value",0.00);
            downpayment.set("v.disabled",true);
        }

        var downpaymentAmt = component.find("downPaymentAmt");
        if(!$A.util.isUndefined(downpaymentAmt)){
            downpaymentAmt.set("v.value",0.00);
            downpaymentAmt.set("v.disabled",true);
        }
        for(var  x in renderedFields){
            if(!$A.util.isUndefinedOrNull(obj)&& obj.hasOwnProperty(renderedFields[x].get('v.fieldName')))
                renderedFields[x].set("v.value",obj[renderedFields[x].get('v.fieldName')]);
            if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'|| renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c'|| renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c' || renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Shipping_Amount__c'){
                renderedFields[x].set("v.value",0.00);
                renderedFields[x].set("v.disabled",true);
            }
            if(renderedFields[x].get('v.fieldName')==='ERP7__Down_Payment__c')
                renderedFields[x].set('v.value',0);
            if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Date__c')
                renderedFields[x].set('v.value',component.get("v.today"));
            if(renderedFields[x].get('v.fieldName')==='ERP7__Organisation__c' || renderedFields[x].get('v.fieldName')==='ERP7__Account__c')
                renderedFields[x].set("v.value",'');
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
            toastEvent.fire();
        }

    },


    OrderProcess : function(cmp, event, helper) {
        var action = cmp.get("c.getFunctionalityControlOrderProcess");
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(response.getReturnValue()){
                    this.getFieldsSetApiNameHandler(cmp,'ERP7__Invoice__c','ERP7__Create_Order_Invoice');
                }else{
                    this.getFieldsSetApiNameHandler(cmp,'ERP7__Invoice__c','erp7__createinvoice');
                }
            }
        });
        $A.enqueueAction(action);

    },


    functionalityControl : function(cmp, event, helper) {
        var action = cmp.get("c.getFuntionalityControl");
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(response.getReturnValue()!=null){
                    try{
                        cmp.set("v.disSchTax", response.getReturnValue().ERP7__Display_Tax_Percentage_for_scheduled_inv__c);
                        cmp.set("v.enableSchTax", response.getReturnValue().ERP7__Allow_scheduled_invoice_tax_editing__c);
                        cmp.set("v.disableSubTotal", response.getReturnValue().ERP7__disableSubTotalOnInvoice__c);
                        cmp.set("v.doneShowAdvanceAppliedAmount", response.getReturnValue().ERP7__Dont_show_Advance_applied_in_invoice__c);
                        cmp.set("v.manageCOGS", response.getReturnValue().ERP7__Manage_COGS__c);
                    }catch(e){
                        console.log('err',e);
                    }
                }
            }
        });
        $A.enqueueAction(action);

    },
})