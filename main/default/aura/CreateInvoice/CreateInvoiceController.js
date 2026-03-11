({
    doInit : function(comp, event, helper) {
        console.log('do init create inv');
        //helper.fetchCurrencyIso(comp);
        comp.set("v.showMmainSpin",true);
        helper.getInstancesAndRecordTypes(comp, event, helper);
        helper.functionalityControl(comp, event, helper);
        //helper.getInstancesAndRecordTypes1(comp, event, helper);
        if(!$A.util.isEmpty(comp.get("v.SOId")))
            helper.getFieldsSetApiNameHandler(comp,'ERP7__Invoice__c','erp7__createinvoice');
        else if(!$A.util.isEmpty(comp.get("v.StdId")))
            helper.getFieldsSetApiNameHandler(comp,'ERP7__Invoice__c','ERP7__Create_Order_Invoice');
        else if(comp.get("v.MultiOrder")==true){
            helper.getFieldsSetApiNameHandler(comp,'ERP7__Invoice__c','erp7__createinvoice');
        }
        else{
                helper.OrderProcess(comp, event, helper);
            }
        //comp.set("v.showMmainSpin",false);
        //helper.checkMultipleCurrency(comp);

        //helper.getFieldsSetApiNameHandler(comp,'ERP7__Invoice__c','erp7__createinvoice');

        var now =  new Date();
        comp.set('v.today',now.getFullYear()+'-'+(now.getMonth()+1)+'-'+now.getDate());
        if(!$A.util.isEmpty(comp.get("v.SOId")) && comp.get("v.selectedrecordTypeMap.DeveloperName")!='On_Account_Payment'){
            comp.set("v.defaultValues",{'ERP7__Order__c':comp.get("v.SOId"),'ERP7__Invoice_Date__c':now.getFullYear()+'-'+(now.getMonth()+1)+'-'+now.getDate()});

        }
        if(!$A.util.isEmpty(comp.get("v.StdId")) && comp.get("v.selectedrecordTypeMap.DeveloperName")!='On_Account_Payment'){
            comp.set("v.defaultValues",{'ERP7__Order_S__c':comp.get("v.StdId"),'ERP7__Invoice_Date__c':now.getFullYear()+'-'+(now.getMonth()+1)+'-'+now.getDate()});

        }
        comp.set("v.showMmainSpin",false);
    },

    cancel : function(comp, event, helper) {

        if(comp.get("v.FromAR")){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:AccountsReceivable",
                componentAttributes: {
                    "showTabs" : 'inv'
                }
            });
            evt.fire();
        }else if(comp.get("v.StdId") != ''){
            console.log('StdId:',comp.get("v.StdId"));
            try{

                /*var workspaceAPI = comp.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                })
                .catch(function(error) {
                    console.log(error);
                });*/
                /*window.setTimeout(
                    $A.getCallback(function() {
                        window.close();
                    }), 1000
                );*/
            }catch(e){console.log('Error:',e);}

            //let url='www.google.com';
            //location.replace("www.google.com");

            /**/
            //window.location.replace(url);
            //window.history.pushState('', '', 'www.google.com');
            //history.back();
            /*var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": comp.get("v.StdId"),
            });
            navEvt.fire(); */

        } else{
            history.back();
        }

    },

    displayNext : function(c, e, h) {
        c.set("v.NDisplay",true);
    },

    next : function(c, e, h) {
        let valArr = c.find("invoiceRecordType").get("v.value").split('@');

        if(valArr.length>1){
            c.set("v.selectedrecordTypeMap",{'RecordTypeId':valArr[0],'DeveloperName':valArr[1]});
        }
        if(c.get("v.selectedrecordTypeMap.DeveloperName")==='On_Account_Payment'){
            var invilist = [];
            invilist.push({'ERP7__Total_Price__c':0.00,'ERP7__Sub_Total__c':0.00,'ERP7__Description__c':'','ERP7__VAT_Amount__c':0.00});
            console.log('invilist : ',invilist);
            c.set("v.INVLIList",invilist);
        }
        console.log('INVLIList : ',c.get("v.INVLIList"));
    },

    handleInvoiceSuccess: function(cmp, event, helper) {
        var payload = event.getParams().response;
        cmp.set("v.invrecordId",payload.id);
        if(payload.id) helper.CreateInvoiceAndLineItem(cmp,event,helper);
    },

    onchangeInvoiceField: function(cmp, event, helper) {

        var sourceField = event.getSource();
        console.log('sourceField', sourceField);

        switch(sourceField.get("v.fieldName")) {
            case 'ERP7__Order__c':
                if(cmp.get("v.selectedrecordTypeMap.DeveloperName")!='On_Account_Payment'){

                    cmp.set("v.SO_Id",sourceField.get("v.value"));
                    cmp.set("v.SOId",sourceField.get("v.value"));
                    helper.getInvoiceLineItem(cmp);
                    helper.fetchOrderInfo(cmp);
                    helper.fetchScheduleInvoices(cmp);
                }
                break;
            case 'ERP7__Order_S__c':
                if(cmp.get("v.selectedrecordTypeMap.DeveloperName")!='On_Account_Payment'){

                    cmp.set("v.Std_Id",sourceField.get("v.value"));
                    cmp.set("v.StdId",sourceField.get("v.value"));
                    helper.getInvoiceLineItem(cmp);
                    helper.fetchStnOrderInfo(cmp);
                    helper.fetchScheduleInvoices(cmp);
                }
                break;
            case 'ERP7__Account__c':
                if(cmp.get("v.selectedrecordTypeMap.DeveloperName")==='On_Account_Payment'){
                    helper.getAccountInformation(cmp,sourceField.get("v.value"));
                    var invliList =  cmp.find("invli");
                    for(let x in invliList)
                        invliList[x].set("v.disabled",false);
                }
                // fetch Tax percentage from customer profile
                break;
            default:
                // code block
        }
    },

    setDefaultValues : function(component, event, helper) {
        component.set("v.showMmainSpin69",true);
		console.log('called setDefaultValues');
        		console.log('invrecordId', component.get("v.invrecordId"));

        if($A.util.isUndefinedOrNull(component.get("v.invrecordId"))){

            helper.setDefaulthandler(component);

            if(!$A.util.isEmpty(component.get("v.SOId"))){
                component.set("v.SO_Id",component.get("v.SOId"));
                helper.fetchTotalDownPayment(component);
                helper.getInvoiceLineItem(component);
                helper.fetchOrderInfo(component);
                helper.fetchScheduleInvoices(component);
            }
            if(!$A.util.isEmpty(component.get("v.StdId"))){
                component.set("v.Std_Id",component.get("v.StdId"));
                helper.fetchTotalDownPayment(component);
                helper.getInvoiceLineItem(component);
                helper.fetchStnOrderInfo(component);
                helper.fetchScheduleInvoices(component);
            }
            if(component.get("v.SalOrdIdsList").length > 0){
                //helper.fetchTotalDownPayment(component);
                helper.getInvoiceLineItems(component);
                helper.fetchMultiOrderInfo(component);
                //helper.fetchScheduleInvoices(component);
            }
            if(component.get("v.OrdIdsList").length > 0){
                //helper.fetchTotalDownPayment(component);
                helper.getInvoiceLineItems(component);
                helper.fetchMultiStnOrderInfo(component);
                //helper.fetchScheduleInvoices(component);
            }
        }
       setTimeout($A.getCallback(function() {
            component.set("v.showMmainSpin69", false);
        }), 6000);
    },

    handleSubmit: function(component, event, helper) {

        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');
        fields.RecordTypeId = component.get("v.selectedrecordTypeMap").RecordTypeId ;
        component.find('invoiceEditForm').submit(fields);
    },

    calculateDownPaymentPercentage: function(component, event, helper) {

        var renderedFields = component.find("inv_input_field");
        for(var  x in renderedFields){
            if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                shippingPrice = renderedFields[x].get("v.value");
                break;
            }
        }
    },
/*
    calculateDownPaymentAmt: function(component, event, helper) {

        var val = event.getSource().get("v.value");
        if(val>=1 && val<=100){
            var renderedFields = component.find("inv_input_field");
            var downPaymentAmt = component.find("downPaymentAmt");
            for(var  x in renderedFields){
                if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c')
                    if(downPaymentAmt != undefined) downPaymentAmt.set("v.value",(renderedFields[x].get("v.value") * val)/100);
                if(renderedFields[x].get('v.fieldName')==='ERP7__Total_Down_Payment_Amount__c'){
                    component.set("v.downPaymentAmount", downPaymentAmt.get("v.value"));
                    renderedFields[x].set('v.value',downPaymentAmt.get("v.value"));
                }

                if(renderedFields[x].get('v.fieldName')==='ERP7__Down_Payment__c'){
                    component.set("v.downPaymentPercentage",val);
                    renderedFields[x].set('v.value',val);
                }



            }
        }
    },
*/

    calculateDownPaymentAmt: function(component, event, helper) {
    var val;

        console.log
    // Check if the function is called via event or manually
    if (event && event.getSource) {
        val = event.getSource().get("v.value");
    } else {
        var downPaymentField = component.find("downPayment");
        val = downPaymentField ? downPaymentField.get("v.value") : 0;
    }

    if (val >= 1 && val <= 100) {
        var renderedFields = component.find("inv_input_field");
        var downPaymentAmt = component.find("downPaymentAmt");

        for (var x in renderedFields) {
            if (renderedFields[x].get('v.fieldName') === 'ERP7__Invoice_Amount__c') {
                var invoiceAmt = renderedFields[x].get("v.value");
                var calculatedDP = (invoiceAmt * val) / 100;
                if (downPaymentAmt !== undefined) {
                    downPaymentAmt.set("v.value", calculatedDP);
                }
            }

            if (renderedFields[x].get('v.fieldName') === 'ERP7__Total_Down_Payment_Amount__c') {
                component.set("v.downPaymentAmount", downPaymentAmt.get("v.value"));
                renderedFields[x].set("v.value", downPaymentAmt.get("v.value"));
            }

            if (renderedFields[x].get('v.fieldName') === 'ERP7__Down_Payment__c') {
                component.set("v.downPaymentPercentage", val);
                renderedFields[x].set("v.value", val);
            }
        }
    }
},


    updateTotalPrice : function(component, event, helper) {
        component.set("v.changeTD", true);
        if(component.get("v.TDPayment")=='' || component.get("v.TDPayment")==null || component.get("v.TDPayment")==undefined){
            component.set("v.TDPayment", 0);
        }
        var renderedFields = component.find("inv_input_field");
        //var downPaymentAmt = component.find("downPaymentAmt");
        for(var  x in renderedFields){
            if(renderedFields[x].get('v.fieldName')==='ERP7__Total_Down_Payment_Amount__c')
                renderedFields[x].set('v.value',component.get("v.TDPayment"));
        }
        helper.updateTotalPrice_Handler(component);
    },

    addInvoiceLineItem:function(comp,event,helper){

        var ILIList=[];
        ILIList=comp.get("v.ILIList");
        var action = comp.get("c.getInvoiceAndLineItemInstance");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (comp.isValid() && state === "SUCCESS") {
                if(ILIList==null) ILIList=response.getReturnValue();
                else ILIList.push(response.getReturnValue());
                comp.set("v.ILIList",ILIList);
            }else{
                console.log('Error:',response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getDelete:function(comp,event,helper){

        var Index=event.getSource().get("v.value");//event.currentTarget.dataset.service;
        var INVLIList=comp.get("v.INVLIList");

        INVLIList.splice(Index,1);
        comp.set("v.INVLIList",INVLIList);
        helper.updateTotalPrice_Handler(comp);
    },

    CreateInvoiceAndLineItem:function(comp,event,helper){
        try{
            console.log('CreateInvoiceAndLineItem');
            if(comp.get("v.selectedrecordTypeMap.DeveloperName")==='Schedule_Invoice'){
                var remainingAmount = (comp.get("v.advancePaymentPaidAmount") - comp.get("v.TotalPaidAmountApplied"));
                console.log('remainingAmount 556677: ',remainingAmount);
                console.log('PaidAmountApplied : ',comp.get("v.PaidAmountApplied"));
                
                   /* if (comp.get("v.PaidAmountApplied") < 0) {//added by Saqlain Khan
                    comp.set("v.showToast", true);
                    comp.set("v.message", "Paid amount applied can't be  negative value.");
                    window.setTimeout(
                        $A.getCallback(function() {
                            comp.set("v.showToast", false);
                        }), 5000
                    );
                    return;
                }else */ if (parseFloat(comp.get("v.subTotal")) < 0 || isNaN(parseFloat(comp.get("v.subTotal")))) {
                            comp.set("v.showToast", true);
                            comp.set("v.message", "Invoice Sub Total cannot be a negative value.");
                            comp.set("v.showMmainSpin", false);
                            window.setTimeout(
                        $A.getCallback(function() {
                            comp.set("v.showToast", false);
                        }), 5000
                    );
                    return;
                }
                    else{
                        console.log('end ');
                    }
                
             /*   if(comp.get("v.PaidAmountApplied") > remainingAmount.toFixed(2)){//Moin Added this .toFixed(2)
                    
                    console.log('in');
                    comp.set("v.showToast",true);
                    console.log('just checking PaidAmountApplied',comp.get("v.PaidAmountApplied"));
                 console.log('just checking remainingAmount', remainingAmount.toFixed(2));

                    
                    comp.set("v.message","Paid amount applied is greater than advance payment");
                    console.log('because of this its shwoing error ');
                    window.setTimeout(
                        $A.getCallback(function() {
                            comp.set("v.showToast",false);
                        }), 5000
                    );
                    return;
                }else{
                    console.log('inhere else');
                } */
                
                var paidAmountApplied = parseFloat(comp.get("v.PaidAmountApplied"));
                    var remaining = parseFloat(remainingAmount.toFixed(2));
                    
                    if (paidAmountApplied > remaining) {
                        console.log('in');
                        comp.set("v.showToast", true);
                        console.log('just checking PaidAmountApplied', paidAmountApplied);
                        console.log('just checking remainingAmount', remaining);
                    
                        comp.set("v.message", "Paid amount applied is greater than advance payment");
                        console.log('because of this its showing error');
                        window.setTimeout(
                            $A.getCallback(function () {
                                comp.set("v.showToast", false);
                            }), 5000
                        );
                        return;
                    } else {
                        console.log('inhere else');
                    }

            }
            comp.set("v.showMmainSpin",true);

            if(comp.get("v.selectedrecordTypeMap.DeveloperName")==='On_Account_Payment'){
                var invli = comp.find("invli");
                var valid = true;
                for(var x in invli){
                    if(invli[x].get("v.required") && (!invli[x].checkValidity() || invli[x].get("v.value")== 0.00)){
                        invli[x].setCustomValidity('Value must be > 0.00');
                        valid = false;
                    }else
                        invli[x].setCustomValidity('');
                    invli[x].showHelpMessageIfInvalid();
                }
                if(valid){
                    comp.find("RecordTypeId").set("v.value",comp.get("v.selectedrecordTypeMap").RecordTypeId);
                    comp.find("invoiceEditForm").submit();
                } else{
                    comp.set("v.showToast",true);
                    comp.set("v.message","Review All Error Messages");

                    setTimeout(
                        $A.getCallback(function() {
                            comp.set("v.showToast",false);
                        }), 3000
                    );
                    //helper.showToast('error','error','Review All Error Messages');
                }
            }
            else{
                var actualInvLIIndex=comp.get('v.actualInvLIIndex');

                console.log('v.subTotal~>'+comp.get('v.subTotal'));
                console.log('v.invTax~>'+comp.get('v.invTax'));
                console.log('v.schInvAmount~>'+comp.get('v.schInvAmount'));
                console.log('v.schInvCreditAmount~>'+comp.get('v.schInvCreditAmount'));

                
                // 🧾 Step-by-step logging for total amount calculation
                var subTotal = parseFloat(comp.get("v.subTotal")) || 0;
                var invTax = parseFloat(comp.get("v.invTax")) || 0;
                var schInvAmount = parseFloat(comp.get("v.schInvAmount")) || 0;
                var schInvCreditAmount = parseFloat(comp.get("v.schInvCreditAmount")) || 0;
                
                // Log each part clearly
                console.log("🔹 Sub Total:", subTotal);
                console.log("🔹 Invoice Tax:", invTax);
                console.log("🔹 Schedule Invoice Amount:", schInvAmount);
                console.log("🔹 Schedule Credit Amount:", schInvCreditAmount);
				console.log("Invoice amt",comp.get("v.InvAmount"));
                console.log("====================")
                console.log("The orderAmount:", comp.get("v.orderAmount"));

                var tatalamount = parseFloat(comp.get("v.subTotal"))+parseFloat(comp.get("v.invTax"))+parseFloat(comp.get("v.schInvAmount")) - parseFloat(comp.get("v.schInvCreditAmount"));//+ parseFloat(comp.get("v.AmountPaid"))
            

                // var tatalamount =  parseFloat(comp.get("v.orderAmount")) - parseFloat(comp.get("v.subTotal")) + parseFloat(comp.get("v.invTax")) + parseFloat(comp.get("v.schInvAmount")) - parseFloat(comp.get("v.schInvCreditAmount"));
                // tatalamount = parseFloat(tatalamount.toFixed(2));
                
                // Final result
                console.log("✅ Final Total Amount:", tatalamount); 
                
                
                //alert(tatalamount);
                console.log('tatalamount : ',tatalamount);
                console.log('v.salesorder.ERP7__Order_Amount__c~>'+comp.get('v.salesorder.ERP7__Order_Amount__c'));
                console.log('v.orderAmount~>'+comp.get('v.orderAmount'));
                try{
                    if(comp.get("v.AmountPaid") == undefined || comp.get("v.AmountPaid") == null){
                        comp.set("v.AmountPaid",0);
                    }
                    if(comp.get("v.AmountPaid") == '') comp.set("v.AmountPaid",0);
                    console.log('v.AmountPaid~>'+comp.get('v.AmountPaid'));

                    if(actualInvLIIndex.length==0){
                        comp.set("v.showToast",true);
                        comp.set("v.message","Please select the invoice Line Item.");

                        setTimeout(
                            $A.getCallback(function() {
                                comp.set("v.showToast",false);
                            }), 3000000
                        );
                        comp.set("v.showMmainSpin",false);
                        //helper.showToast('error','error','Please select the invoice Line Item');
                        console.log('toast total amt',tatalamount);
                        console.log("toast order amt ",parseFloat(comp.get('v.orderAmount')));
                    }else if(comp.get("v.selectedrecordTypeMap.DeveloperName")==='Schedule_Invoice' && tatalamount > parseFloat(comp.get('v.orderAmount'))){
                        comp.set("v.showToast",true);
                        comp.set("v.message","Sum of scheduled amount is greater then order amount");

                        setTimeout(
                            $A.getCallback(function() {
                                comp.set("v.showToast",false);
                            }), 3000
                        );
                        comp.set("v.showMmainSpin",false);
                    }else if(comp.get("v.selectedrecordTypeMap.DeveloperName")==='Advance' && (comp.get("v.downPaymentAmount")<=0 || $A.util.isEmpty(comp.get("v.downPaymentAmount")))){
                        comp.set("v.showToast",true);
                        comp.set("v.message","Please Enter the Down Payment Percentage or Amount");

                        setTimeout(
                            $A.getCallback(function() {
                                comp.set("v.showToast",false);
                            }), 3000
                        );
                        comp.set("v.showMmainSpin",false);
                    }else if(comp.get("v.selectedrecordTypeMap.DeveloperName")==='Advance' && (comp.get("v.downPaymentPercentage")>100 || $A.util.isEmpty(comp.get("v.downPaymentPercentage")))){
                        comp.set("v.showToast",true);
                        comp.set("v.message","Down Payment Amount is more than 100%");

                        setTimeout(
                            $A.getCallback(function() {
                                comp.set("v.showToast",false);
                            }), 3000
                        );
                        comp.set("v.showMmainSpin",false);
                    }else if(comp.get("v.AmountPaid") != undefined && comp.get("v.AmountPaid") != null && comp.get("v.AmountPaid") > 0 && comp.get("v.PaidAmountApplied")!=null && comp.get("v.PaidAmountApplied")!=undefined && comp.get("v.PaidAmountApplied") > 0 && comp.get("v.PaidAmountApplied")>comp.get("v.AmountPaid")){
                        console.log('in here Paid Amount Applied is greater then the Advance Payment');
                        comp.set("v.showToast",true);
                        comp.set("v.message","Paid Amount Applied is greater then the Advance Payment");

                        setTimeout(
                            $A.getCallback(function() {
                                comp.set("v.showToast",false);
                            }), 3000
                        );
                        comp.set("v.showMmainSpin",false);
                    }else{
                        console.log('in here here');
                        var invli = comp.find("invli");
                        var valid = true;
                        if($A.util.isUndefined((invli.length))){
                            invli.checkValidation();
                            if(!invli.get("v.validate")) valid = false;
                        }else{
                            for(var x in invli){
                                invli[x].checkValidation();
                                if(!invli[x].get("v.validate"))
                                    valid = false;
                            }
                        }

                        if(valid){
                            //comp.find("RecordTypeId").set("v.value",comp.get("v.selectedrecordTypeMap").RecordTypeId);
                            //helper.showToast('success','success','Invoice Created Successfully');
                            var renderedFields = comp.find("inv_input_field");
                            //alert(comp.get("v.Invoice.ERP7__Invoice_Date__c"));
                            for(var  x in renderedFields){
                                comp.set("v.NewInvoice.RecordTypeId", comp.get("v.selectedrecordTypeMap").RecordTypeId);
                                if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Date__c'){
                                    comp.set("v.NewInvoice.ERP7__Invoice_Date__c",renderedFields[x].get("v.value"));
                                }
                                if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                                    comp.set("v.NewInvoice.ERP7__Invoice_Amount__c",renderedFields[x].get("v.value"));
                                }
                                if(renderedFields[x].get('v.fieldName')==='ERP7__Down_Payment__c'){
                                    comp.set("v.NewInvoice.ERP7__Down_Payment__c",renderedFields[x].get("v.value"));
                                }
                                if(renderedFields[x].get('v.fieldName')==='ERP7__Total_Down_Payment_Amount__c'){
                                    comp.set("v.NewInvoice.ERP7__Total_Down_Payment_Amount__c",renderedFields[x].get("v.value"));
                                }
                                if(renderedFields[x].get('v.fieldName')==='ERP7__Sales_Invoice_Percentage__c'){
                                    comp.set("v.NewInvoice.ERP7__Sales_Invoice_Percentage__c",renderedFields[x].get("v.value"));
                                }
                                if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                                    comp.set("v.NewInvoice.ERP7__Invoice_Amount__c",renderedFields[x].get("v.value"));
                                }
                                if(renderedFields[x].get('v.fieldName')==='ERP7__Amount_Paid__c'){
                                    comp.set("v.NewInvoice.ERP7__Amount_Paid__c",renderedFields[x].get("v.value"));
                                }
                                if(renderedFields[x].get('v.fieldName')==='ERP7__Sales_Invoice_Tax_Percentage__c'){
                                    comp.set("v.NewInvoice.ERP7__Sales_Invoice_Tax_Percentage__c",renderedFields[x].get("v.value"));
                                }
                                if(renderedFields[x].get('v.fieldName')==='ERP7__Sub_Total_Amount__c'){
                                    comp.set("v.NewInvoice.ERP7__Sub_Total_Amount__c",renderedFields[x].get("v.value"));
                                }
                                if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Shipping_Amount__c'){
                                    comp.set("v.NewInvoice.ERP7__Invoice_Shipping_Amount__c",renderedFields[x].get("v.value"));
                                }
                                if(renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c'){
                                    comp.set("v.NewInvoice.ERP7__Tax_Amount__c",renderedFields[x].get("v.value"));
                                }
                                if(renderedFields[x].get('v.fieldName')==='ERP7__Discount_Amount__c'){
                                    comp.set("v.NewInvoice.ERP7__Discount_Amount__c",renderedFields[x].get("v.value"));
                                }
                                if(renderedFields[x].get('v.fieldName')==='ERP7__Paid_Amount_Applied__c'){
                                      // added new to not save the ERP7__Paid_Amount_Applied__c value if its only the shedule invoice 
                                    
                                    			var schInvoiceList = comp.get('v.schInvoiceList') || [];
                                                var advanceInvoiceList = comp.get('v.advanceInvoiceList') || [];
                                            
                                                var schCount = Array.isArray(schInvoiceList) ? schInvoiceList.length : 0;
                                                var advCount = Array.isArray(advanceInvoiceList) ? advanceInvoiceList.length : 0;
                                            
                                                console.log('The schInvoiceList value', JSON.stringify(schInvoiceList));
                                                console.log('The advanceInvoiceList value', JSON.stringify(advanceInvoiceList));
                                                console.log('schCount:', schCount, 'advCount:', advCount, 'IF? ->', (schCount > 0 && advCount === 0));
                                            
                                                // ✅ IF: at least one schedule invoice and NO advance invoices
                                                if (schCount > 0 && advCount === 0) {
                                                    console.log('Condition met: ≥1 schInvoice and no advanceInvoice');
                                                }
                                    else{
                                      comp.set("v.NewInvoice.ERP7__Paid_Amount_Applied__c",renderedFields[x].get("v.value"));

                                    }
                                }
                            }
                            if(!$A.util.isEmpty(comp.get("v.SOId")))
                                comp.set("v.NewInvoice.ERP7__Order__c",comp.get("v.SOId"));
                            if(!$A.util.isEmpty(comp.get("v.StdId")))
                                comp.set("v.NewInvoice.ERP7__Order_S__c",comp.get("v.StdId"));
                            // 🕒 Delay final printout by 2 seconds
// setTimeout(function() {
//     //alert(tatalamount);
//     console.log('tatalamount : ', tatalamount);
//     console.log('✅ Final Total Amount (after timeout):', tatalamount);
//     helper.CreateInvoiceAndLineItem(comp,event,helper);
// }, 9000);
                           helper.CreateInvoiceAndLineItem(comp,event,helper);
                            /*setTimeout(
                                $A.getCallback(function() {
                                    comp.find("invoiceEditForm").submit();
                                }), 2000
                            );*/
                        }
                        else{

                            comp.set("v.showToast",true);
                            comp.set("v.message","Review All Error Messages");

                            setTimeout(
                                $A.getCallback(function() {
                                    comp.set("v.showToast",false);
                                }), 3000
                            );
                            //helper.showToast('error','error','Review All Error Messages');
                            comp.set("v.showMmainSpin",false);
                        }
                    }
                }catch(e){
                    console.log('arshad err1',e);
                }
            }

        }catch(e){
            console.log('arshad err2',e);
        }
    },

    calculateAmount:function(comp,event,helper){

        var invli = comp.get("v.INVLIList");
        var fields = comp.find("invli");
        var tax = 0.00;
        var taxAmount =0.00;
        var totalAmount = 0.00;
        for(let x in fields)
            if(fields[x].get("v.name")==='tax'){
                tax=fields[x].get("v.value");
                break;
            }

        for(var x in invli){
            taxAmount = parseFloat(tax)*invli[x].ERP7__Sub_Total__c;
            invli[x].ERP7__VAT_Amount__c = taxAmount;
            totalAmount =  parseFloat(invli[x].ERP7__VAT_Amount__c) + parseFloat(invli[x].ERP7__Sub_Total__c);
            invli[x].ERP7__Total_Price__c = totalAmount;

        }
        console.log('invli : ',invli);
        comp.set("v.INVLIList",invli);
        var renderedFields = comp.find("inv_input_field");

        for(var  x in renderedFields){
            if( renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c'){
                renderedFields[x].set("v.value",taxAmount);
                component.set("v.invTax", taxAmount);
            }
            if( renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c')
                renderedFields[x].set("v.value",totalAmount);
            // if( renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Shipping_Amount__c')
            //   renderedFields[x].set("v.value",100);
        }

    },

    fetchInvoiceLineItems:function(comp,event,helper){

        var ILIList=[];//comp.get("v.ILIList");
        var action = comp.get("c.getInvoiceLineItem");
        action.setParams({
            "SOId":comp.get("v.Invoice.ERP7__Order__c") //InvoiceOrder.Id Invoice.ERP7__Order__c.Id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (comp.isValid() && state === "SUCCESS") {

                for(var i in response.getReturnValue())
                    ILIList.push(response.getReturnValue()[i]);

                //comp.set("v.ILIList",ILIList);

            }else{
                console.log('Error:',response.getError());
            }
        });
        $A.enqueueAction(action);

    },

    cancelCreateInvoiceAndLineItem:function(comp,event,helper){

        if(comp.get("v.FromAR")){
            $A.createComponent(
                "c:AccountsReceivable", {
                    "showTabs":comp.get("v.showTabs"),
                    "fetchRecordsBool":false,
                    "Organisation":comp.get("v.Organisation")
                },
                function(newComp) {
                    var content = comp.find("body");
                    content.set("v.body", newComp);
                }
            );
        }else {
            history.back();
            /*if(comp.get("v.SOId")==undefined || comp.get("v.SOId")=='' || comp.get("v.SOId")==null || comp.get("v.StdId")==undefined || comp.get("v.StdId")=='' || comp.get("v.StdId")==null){
            $A.createComponent(
                "c:AccountsReceivable", {
                    "showTabs":comp.get("v.showTabs"),
                    "fetchRecordsBool":false,
                    "Organisation":comp.get("v.Organisation")
                },
                function(newComp) {
                    var content = comp.find("body");
                    content.set("v.body", newComp);
                }
            );
        }else {
            history.back();
            }
            */

        }

    },

    CancelCalled : function(comp, event, helper){

        if(comp.get("v.FromAR")){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:AccountsReceivable",
                componentAttributes: {
                    "showTabs" : 'inv'
                }
            });
            evt.fire();
        }
        else{
            history.back();
        }
    },

    getallinvoiceLI : function(cmp, event, helper){
        try{
            let checked = false;
            if(event != undefined){
                checked = event.getSource().get("v.checked");
                console.log('checked : ',checked);
                var allbbox = cmp.find("boxPack");
                if(allbbox.length>0){
                    for(var x in allbbox) allbbox[x].set("v.value",checked);
                }else allbbox.set("v.value",checked);
                var actualInvLIIndex = [];//cmp.get('v.actualInvLIIndex');
                var actualInvLI = [];//cmp.get('v.actualInvLI');
                var invli=cmp.get("v.INVLIList");

                if(checked){
                    cmp.set("v.allChecked",true);
                    for(var ind in invli ){
                        actualInvLIIndex.push(ind);
                        actualInvLI.push(invli[ind]);
                        cmp.set('v.actualInvLI',actualInvLI);
                        cmp.set('v.actualInvLIIndex',actualInvLIIndex);
                    }
                }
                else{
                    cmp.set("v.allChecked",false);
                    var INVLIList=cmp.get("v.INVLIList");
                    var actList=[];
                    var actINVList=[];
                    /*for(var j in INVLIList){
                actINVList.push(j);
            }*/
                    cmp.set('v.actualInvLI',actList);
                    cmp.set("v.actualInvLIIndex",actINVList);

                }
            }
            helper.updateTotalPrice_Handler(cmp);
              $A.enqueueAction(cmp.get("c.calculateDownPaymentAmt"));
           $A.enqueueAction(cmp.get("c.calculateDownPaymentPercentag"));
        }catch(err){
            console.log('err : ',err);
        }
    },

    getinvoiceLI : function(cmp, event, helper){

        var allbbox = cmp.find("select");
        allbbox.set("v.checked",false);
        var actualInvLIIndex = cmp.get('v.actualInvLIIndex');
        var actualInvLI = cmp.get('v.actualInvLI');

        var invli=cmp.get("v.INVLIList");

        if(event.getSource().get("v.checked")){

            for(var ind in invli ) {
                if(ind==event.getSource().get("v.name")){
                    actualInvLIIndex.push(ind);
                    actualInvLI.push(invli[ind]);
                    cmp.set('v.actualInvLI',actualInvLI);
                    cmp.set('v.actualInvLIIndex',actualInvLIIndex);

                }

            }

        }
        else{

            var INVLIList=cmp.get("v.actualInvLIIndex");
            var actList=[];
            var index=event.getSource().get("v.name");
            var act=cmp.get('v.actualInvLI');
            var actINVList=[];
            for(var j in INVLIList){
                if(INVLIList[j]!=index){
                    actList.push(act[j]);
                    actINVList.push(INVLIList[j]);
                }
            }
            cmp.set('v.actualInvLI',actList);
            cmp.set("v.actualInvLIIndex",actINVList);

        }
        helper.updateTotalPrice_Handler(cmp);

        $A.enqueueAction(cmp.get("c.calculateDownPaymentAmt"));
           $A.enqueueAction(cmp.get("c.calculateDownPaymentPercentag"));
    },

    onCheck : function(c, e, h){

        var shipping_tax_ammount =0,old=0,shipping_amount = 0;


        if(c.get('v.enableShipping'))
        {shipping_tax_ammount=c.get('v.salesorder.ERP7__Shipping_VAT__c');
         shipping_amount=c.get('v.salesorder.ERP7__Total_Shipping_Amount__c');
         if(shipping_tax_ammount==null || shipping_tax_ammount=='')shipping_tax_ammount=0;
         if(shipping_amount==null || shipping_amount=='')shipping_amount=0;
         var renderedFields = c.find("inv_input_field");
         for(var  x in renderedFields){
             if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Shipping_Amount__c'){
                 old = renderedFields[x].get("v.value");
                 if(old==null || old=='')old=0;
                 renderedFields[x].set("v.value",parseFloat(old+shipping_amount));
             }
             if(renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c'){
                 old = renderedFields[x].get("v.value");
                 if(old==null || old=='')old=0;
                 renderedFields[x].set("v.value",parseFloat(old+shipping_tax_ammount));
             }
             if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                 old = renderedFields[x].get("v.value");
                 if(old==null || old=='')old=0;
                 renderedFields[x].set("v.value",parseFloat(old+shipping_tax_ammount+shipping_amount));
             }
         }
        }
        else{
            shipping_tax_ammount=c.get('v.salesorder.ERP7__Shipping_VAT__c');
            shipping_amount=c.get('v.salesorder.ERP7__Total_Shipping_Amount__c');
            if(shipping_tax_ammount==null || shipping_tax_ammount=='')shipping_tax_ammount=0;
            if(shipping_amount==null || shipping_amount=='')shipping_amount=0;
            var renderedFields = c.find("inv_input_field");
            for(var  x in renderedFields){
                if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Shipping_Amount__c'){
                    old = renderedFields[x].get("v.value");
                    if(old==null || old=='')old=0;
                    renderedFields[x].set("v.value",parseFloat(old-shipping_amount));
                }
                if(renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c'){
                    old = renderedFields[x].get("v.value");
                    if(old==null || old=='')old=0;
                    renderedFields[x].set("v.value",parseFloat(old-shipping_tax_ammount));
                }
                if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                    old = renderedFields[x].get("v.value");
                    if(old==null || old=='')old=0;
                    renderedFields[x].set("v.value",parseFloat(old-shipping_tax_ammount-shipping_amount));
                }
            }
        }


    },
/*
    calculateDownPaymentPercentag: function(component, event, helper) {

        var val = event.getSource().get("v.value");
        var renderedFields = component.find("inv_input_field");
        //if(val>0 && val<=96){
        var renderedFields = component.find("inv_input_field");
        var downPayment = component.find("downPayment");
        for(var  x in renderedFields){
            if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                if(downPayment != undefined) downPayment.set("v.value",((val/renderedFields[x].get("v.value"))*100).toFixed(2));
            }

            if(renderedFields[x].get('v.fieldName')==='ERP7__Down_Payment__c'){
                component.set("v.downPaymentPercentage",downPayment.get("v.value"));
                renderedFields[x].set('v.value',downPayment.get("v.value"));
            }
            if(renderedFields[x].get('v.fieldName')==='ERP7__Total_Down_Payment_Amount__c'){
                renderedFields[x].set('v.value',val);
                component.set("v.downPaymentAmount", val);
            }



            // }
        }
    },*/

    calculateDownPaymentPercentag: function(component, event, helper) {
    var val;

    // Get value from event if available, otherwise get it from the downPaymentAmt input
    if (event && event.getSource) {
        val = event.getSource().get("v.value");
    } else {
        var dpAmtField = component.find("downPaymentAmt");
        val = dpAmtField ? dpAmtField.get("v.value") : 0;
    }

    var renderedFields = component.find("inv_input_field");
    var downPayment = component.find("downPayment");

    for (var x in renderedFields) {
        if (renderedFields[x].get('v.fieldName') === 'ERP7__Invoice_Amount__c') {
            var invoiceAmt = renderedFields[x].get("v.value");
            if (invoiceAmt && invoiceAmt != 0 && downPayment != undefined) {
                var percent = ((val / invoiceAmt) * 100).toFixed(2);
                downPayment.set("v.value", percent);
            }
        }

        if (renderedFields[x].get('v.fieldName') === 'ERP7__Down_Payment__c') {
            var dpValue = downPayment ? downPayment.get("v.value") : 0;
            component.set("v.downPaymentPercentage", dpValue);
            renderedFields[x].set('v.value', dpValue);
        }

        if (renderedFields[x].get('v.fieldName') === 'ERP7__Total_Down_Payment_Amount__c') {
            renderedFields[x].set('v.value', val);
            component.set("v.downPaymentAmount", val);
        }
    }
},



    calculateInvoiceAmount : function(component, event, helper) {
        try{
            console.log('v.InvAmount:', component.get("v.InvAmount"));

            var val = event.getSource().get("v.value");
            var renderedFields = component.find("inv_input_field");
            //var renderedFields = component.find("inv_input_field");
            var downPaymentAmtSales = component.find("downPaymentAmtSales");
            if(val == null || val == undefined || val == '') val = 0;
            if(val!=null && val!=undefined && val!=''){
                var subTotal = 0.00;//component.get("v.")
                var invli = component.get("v.actualInvLI");
                for(var x in invli){
                    subTotal += parseFloat(invli[x].ERP7__Sub_Total__c);
                }

                for(var  x in renderedFields){
                    if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                        renderedFields[x].set('v.value',((subTotal*val)/100).toFixed(2));
                        // added this new line to set the down payment amount in the downPaymentAmtSales field
                        var val1 = parseFloat(event.getSource().get("v.value")) || 0;

                        // --- Calculate discount amount ---
                        var discountPct = parseFloat(component.get("v.discountAmount")) || 0;
                        var discountAmt = (discountPct * val1 / 100);
                        discountAmt = parseFloat(discountAmt.toFixed(2));
                        var subtotalAfterDiscount = ((subTotal*val)/100).toFixed(2) - discountAmt;
                        subtotalAfterDiscount = parseFloat(subtotalAfterDiscount.toFixed(2));
                        console.log('The discountAmt value: ', discountAmt);
                        console.log('The subtotalAfterDiscount value: ', subtotalAfterDiscount);
                        component.set("v.subTotal", subtotalAfterDiscount);


                       // component.set("v.subTotal", ((subTotal*val)/100).toFixed(2));

                        component.set("v.InvAmount",((subTotal*val)/100).toFixed(2));
                        console.log('inv amt set here 1 '+((subTotal*val)/100).toFixed(2));
                    }
                    if(renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c'){
                        renderedFields[x].set('v.value',0.00);
                        component.set("v.invTax", 0.00);
                        console.log('inv tax set here 0');
                    }
                  /*  if(renderedFields[x].get('v.fieldName')==='ERP7__Paid_Amount_Applied__c'){
                        renderedFields[x].set('v.value',((component.get("v.AmountPaid")*val)/100).toFixed(2));
                        var paidAmountApplied = component.find("paidAmountApplied");
                        if(paidAmountApplied != undefined) paidAmountApplied.set("v.value",((component.get("v.AmountPaid")*val)/100).toFixed(2));
                        component.set("v.PaidAmountApplied", ((component.get("v.AmountPaid")*val)/100).toFixed(2));
                        console.log('PaidAmountApplied 2: ',component.get("v.PaidAmountApplied"));
                        
                         // This new changes done by saqlain 
                        console.log('Calling the function Saqlain fixed');
                        console.log('New advancePaymentPaidAmount: ', component.get("v.advancePaymentPaidAmount"));
                        console.log('New TotalPaidAmountApplied: ', component.get("v.TotalPaidAmountApplied"));
                    
                       
                    }*/
                     // This new changes done by saqlain, this is working fine , when its come to advance and schedule invoive, but only for schedule invoice its getting some rwong calculation.
                     
             

/*
             
       if (renderedFields[x].get('v.fieldName') === 'ERP7__Paid_Amount_Applied__c') {

    var schInvoiceList = component.get('v.schInvoiceList') || [];
    var advanceInvoiceList = component.get('v.advanceInvoiceList') || [];

    var schCount = Array.isArray(schInvoiceList) ? schInvoiceList.length : 0;
    var advCount = Array.isArray(advanceInvoiceList) ? advanceInvoiceList.length : 0;

    console.log('The schInvoiceList value', JSON.stringify(schInvoiceList));
    console.log('The advanceInvoiceList value', JSON.stringify(advanceInvoiceList));
    console.log('schCount:', schCount, 'advCount:', advCount, 'IF? ->', (schCount > 0 && advCount === 0));

    // ✅ IF: at least one schedule invoice and NO advance invoices
    if (schCount > 0 && advCount === 0) {
        console.log('Condition met: ≥1 schInvoice and no advanceInvoice');

        let paidApplied = component.get("v.AmountPaid").toFixed(2);
        renderedFields[x].set('v.value', paidApplied);

        // safe find() (could return array or single cmp)
        let paidAmountApplied = component.find("paidAmountApplied");
        if (Array.isArray(paidAmountApplied)) paidAmountApplied = paidAmountApplied[0];
      //  if (paidAmountApplied) paidAmountApplied.set("v.value", paidApplied);

        let oldPaidAmountApplied = paidApplied;
        console.log('PaidAmountApplied (sch only) - old value:', oldPaidAmountApplied);

        console.log('Calling the function Saqlain fixed');
        console.log('New TotalPaidAmountApplied:', component.get("v.TotalPaidAmountApplied"));
        console.log('New PaidAmountApplied:', paidApplied);

        let totalPaidAmountApplied = component.get("v.TotalPaidAmountApplied");
        let appliedAmount = (totalPaidAmountApplied === 0 || totalPaidAmountApplied === undefined)
            ? parseFloat(paidApplied).toFixed(2)
            : parseFloat(totalPaidAmountApplied).toFixed(2);

      // ❌ No advance payment calculation in this block
           // component.set("v.PaidAmountApplied", appliedAmount);
           // if (paidAmountApplied) paidAmountApplied.set("v.value", appliedAmount);
            
            // ✅ Add detailed logs
            console.log('No-Advance Block Executed');
            console.log('v.InvAmount:', component.get("v.InvAmount"));
            console.log('v.PaidAmountApplied (component value):', component.get("v.PaidAmountApplied"));
            console.log('v.PaidAmountApplied (local variable):', appliedAmount);


    } else {

        // 🔁 Else: Original logic including advance amount calculation
        console.log('Condition met, advanceInvoiceList Found (or no schInvoice)');

      let paidApplied1 = ((component.get("v.AmountPaid") * val) / 100).toFixed(2);
        let paidApplied = ((component.get("v.advancePaymentPaidAmount") * val) / 100).toFixed(2);
        
        console.log('AmountPaid - The  value -: ', component.get("v.AmountPaid"));
        console.log('AmountPaid - The  value -: ', component.get("v.AmountPaid"));
        renderedFields[x].set('v.value', paidApplied);

        let paidAmountApplied = component.find("paidAmountApplied");
        if (Array.isArray(paidAmountApplied)) paidAmountApplied = paidAmountApplied[0];
        if (paidAmountApplied) paidAmountApplied.set("v.value", paidApplied);

        let oldPaidAmountApplied = paidApplied;
        console.log('PaidAmountApplied 2 - The old value -: ', oldPaidAmountApplied);

        console.log('Calling the function Saqlain fixed');
        console.log('New advancePaymentPaidAmount:', component.get("v.advancePaymentPaidAmount"));
        console.log('New TotalPaidAmountApplied:', component.get("v.TotalPaidAmountApplied"));
        console.log('New PaidAmountApplied:', paidApplied);

        let totalPaidAmountApplied = component.get("v.TotalPaidAmountApplied");
        let appliedAmount = (totalPaidAmountApplied === 0 || totalPaidAmountApplied === undefined)
            ? parseFloat(paidApplied).toFixed(2)
            : parseFloat(totalPaidAmountApplied).toFixed(2);
        
        console.log('remainingAmount 69 advancePaymentPaidAmount :', component.get("v.advancePaymentPaidAmount"));
        console.log('remainingAmount 69 appliedAmount:', parseFloat(appliedAmount));
        

        let remainingAmount1 = parseFloat(appliedAmount);
        console.log('remainingAmount 69:', remainingAmount1);

        component.set("v.PaidAmountApplied", remainingAmount1.toFixed(2));
        if (paidAmountApplied) paidAmountApplied.set("v.value", remainingAmount1.toFixed(2));
    }
}
*/

     if (renderedFields[x].get('v.fieldName') === 'ERP7__Paid_Amount_Applied__c') {

    // ===== pre-branch inputs (unchanged logic) =====
    var schInvoiceList = component.get('v.schInvoiceList') || [];
    var advanceInvoiceList = component.get('v.advanceInvoiceList') || [];

    var schCount = Array.isArray(schInvoiceList) ? schInvoiceList.length : 0;
    var advCount = Array.isArray(advanceInvoiceList) ? Array.isArray(advanceInvoiceList) ? advanceInvoiceList.length : 0 : 0;

    var schedulePctRaw = (typeof val === 'string') ? val.trim() : val;
    var schedulePct = parseFloat(schedulePctRaw);
    if (isNaN(schedulePct)) schedulePct = 0;

    var invli = component.get("v.actualInvLI") || [];
    var orderTotal = 0;
    for (var li = 0; li < invli.length; li++) {
        var sub = parseFloat(invli[li].ERP7__Sub_Total__c);
        if (!isNaN(sub)) orderTotal += sub;
    }

    var amountPaid = parseFloat(component.get("v.AmountPaid")); // may be total paid to date
    if (isNaN(amountPaid)) amountPaid = 0;

    var advancePaidAmount = parseFloat(component.get("v.advancePaymentPaidAmount")); // collected advance (e.g., 5000)
    if (isNaN(advancePaidAmount)) advancePaidAmount = 0;

    var totalPaidAmountApplied = parseFloat(component.get("v.TotalPaidAmountApplied"));
    if (isNaN(totalPaidAmountApplied)) totalPaidAmountApplied = 0;

    var subTotalScheduled = parseFloat(component.get("v.subTotal"));
    if (isNaN(subTotalScheduled)) subTotalScheduled = 0;

    var invAmountCurrent = parseFloat(component.get("v.InvAmount"));
    if (isNaN(invAmountCurrent)) invAmountCurrent = 0;

    var scheduleGross_cmp = (orderTotal * schedulePct) / 100;               // % of whole order
    var scheduleAdvancePart_cmp = (advancePaidAmount * schedulePct) / 100;  // % of the advance
    var remainingBase_cmp = orderTotal - advancePaidAmount;                 // whole - advance
    var scheduleAdjusted_cmp = scheduleGross_cmp - scheduleAdvancePart_cmp; // expected net for schedule piece
    if (scheduleAdjusted_cmp < 0) scheduleAdjusted_cmp = 0;

    console.log('================= ⚙️ START: PAID_APPLIED =================');
    console.log('🔹 raw val:', val, '| schedulePctRaw:', schedulePctRaw, '| parsed schedulePct:', schedulePct);
    console.log('🔹 schCount:', schCount, '| advCount:', advCount);
    console.log('🔹 schInvoiceList:', JSON.stringify(schInvoiceList, null, 2));
    console.log('🔹 advanceInvoiceList:', JSON.stringify(advanceInvoiceList, null, 2));
    console.log('🔹 outer orderTotal (Σ Sub_Total__c):', orderTotal.toFixed(2));
    console.log('🔹 v.AmountPaid:', amountPaid.toFixed(2));
    console.log('🔹 v.advancePaymentPaidAmount:', advancePaidAmount.toFixed(2));
    console.log('🔹 v.TotalPaidAmountApplied:', totalPaidAmountApplied.toFixed(2));
    console.log('🔹 v.subTotal:', subTotalScheduled.toFixed(2));
    console.log('🔹 v.InvAmount:', invAmountCurrent.toFixed(2));
    console.log('🔎 cmp.selectedrecordTypeMap?.DeveloperName:', component.get("v.selectedrecordTypeMap") && component.get("v.selectedrecordTypeMap").DeveloperName);
    console.log('----- quick compare math (outer) -----');
    console.log('• scheduleGross_cmp (% of orderTotal):', scheduleGross_cmp.toFixed(2));
    console.log('• scheduleAdvancePart_cmp (% of advance):', scheduleAdvancePart_cmp.toFixed(2));
    console.log('• remainingBase_cmp (orderTotal - advance):', remainingBase_cmp.toFixed(2));
    console.log('• scheduleAdjusted_cmp (gross - advancePart):', scheduleAdjusted_cmp.toFixed(2));
    console.log('• identity: % * remainingBase_cmp =', ((remainingBase_cmp * schedulePct) / 100).toFixed(2));

    var paidAmountApplied = component.find("paidAmountApplied");
    if (Array.isArray(paidAmountApplied)) paidAmountApplied = paidAmountApplied[0];

    if ((component.get("v.selectedrecordTypeMap.DeveloperName")==='Schedule_Invoice' || schCount > 0) && advCount === 0) {
        console.log('🟩 BRANCH: Schedule-only (>=1 schedule, 0 advance)');

        let paidApplied = component.get("v.AmountPaid").toFixed(2);
        renderedFields[x].set('v.value', paidApplied);

        // For comparison, also log the % of AmountPaid
        let pctOfAmountPaid_dbg = ((amountPaid * schedulePct) / 100).toFixed(2);
        console.log('[Schedule-only] legacy set => AmountPaid:', paidApplied);
        console.log('[Schedule-only] compare -> % of AmountPaid:', pctOfAmountPaid_dbg);

        let oldPaidAmountApplied = paidApplied;
        console.log('PaidAmountApplied (sch only) - old value:', oldPaidAmountApplied);

        console.log('New TotalPaidAmountApplied:', component.get("v.TotalPaidAmountApplied"));
        console.log('New PaidAmountApplied (field write):', paidApplied);

        let totalPaidAmountApplied0 = component.get("v.TotalPaidAmountApplied");
        let appliedAmount0 = (totalPaidAmountApplied0 === 0 || totalPaidAmountApplied0 === undefined)
            ? parseFloat(paidApplied).toFixed(2)
            : parseFloat(totalPaidAmountApplied0).toFixed(2);

        console.log('No-Advance Block Executed');
        console.log('v.InvAmount:', component.get("v.InvAmount"));
        console.log('v.PaidAmountApplied (component value):', component.get("v.PaidAmountApplied"));
        console.log('v.PaidAmountApplied (local variable):', appliedAmount0);

  } else {

    // 🔁 Else: Advance present (or no schedule)
    console.log('🟧 BRANCH: Advance present (or no schedule) — BEGIN');

    var schedulePct = parseFloat(val);
    var pctFromSch = schCount > 0
      ? parseFloat(schInvoiceList[0] && schInvoiceList[0].ERP7__Sales_Invoice_Percentage__c)
      : NaN;

    console.log('🔢 [pct] UI val:', val, '-> Parsed:', isNaN(schedulePct) ? 'NaN' : schedulePct,
                '| schedule record %:', isNaN(pctFromSch) ? 'NaN' : pctFromSch);

    if (isNaN(schedulePct) || schedulePct <= 0) {
      schedulePct = !isNaN(pctFromSch) && pctFromSch > 0 ? pctFromSch : 0;
      console.log('↩️ [pct] using fallback %:', schedulePct);
    }
    console.log('✅ [pct final] schedulePct used (inner):', schedulePct);

    // 🔁 re-read (kept)
    var invli = component.get("v.actualInvLI") || [];
    var orderNetInner = 0;
    var taxFromLinesInner = 0; // keep 0 unless you actually populate line tax
    for (var i = 0; i < invli.length; i++) {
      var sub = parseFloat(invli[i].ERP7__Sub_Total__c);
      if (!isNaN(sub)) orderNetInner += sub;
      // If you have per-line tax fields, sum them here into taxFromLinesInner
      // var taxLi = parseFloat(invli[i].ERP7__VAT_Amount__c || invli[i].ERP7__Tax_Amount__c);
      // if (!isNaN(taxLi)) taxFromLinesInner += taxLi;
    }

    var advancePaidAmountInner = parseFloat(component.get("v.advancePaymentPaidAmount"));
    if (isNaN(advancePaidAmountInner)) advancePaidAmountInner = 0;

    // ✅ NEW: prefer the advance invoice's gross as the order gross base
    var advGrossPeek = advCount > 0 ? (parseFloat(advanceInvoiceList[0].ERP7__Invoice_Amount__c) || 0) : 0;
    var orderGrossFallback = orderNetInner + taxFromLinesInner;
    var orderGrossBase = advGrossPeek > 0 ? advGrossPeek : orderGrossFallback;

    // ✅ Use GROSS base minus ADVANCE PAID
    var remainingBase = Math.max(orderGrossBase - advancePaidAmountInner, 0);
    var appliedAmountNum = (remainingBase * schedulePct) / 100;
    appliedAmountNum = isFinite(appliedAmountNum) ? appliedAmountNum : 0;

    // 🔍 logs
    console.log('📦 orderNetInner:', orderNetInner.toFixed(2),
                '| taxFromLinesInner:', taxFromLinesInner.toFixed(2),
                '| orderGrossFallback (net+tax):', orderGrossFallback.toFixed(2));
    console.log('🔎 Advance invoice peek — gross:', advGrossPeek.toFixed(2));
    console.log('🏦 advancePaidAmountInner:', advancePaidAmountInner.toFixed(2));
    console.log('🧮 [RULE] remainingBase = orderGrossBase - advancePaid =',
                orderGrossBase.toFixed(2), '-', advancePaidAmountInner.toFixed(2), '=',
                remainingBase.toFixed(2));
    console.log('🧮 [RULE] applied =', schedulePct, '% *', remainingBase.toFixed(2), '=',
                appliedAmountNum.toFixed(2));

    // writes (unchanged)
    renderedFields[x].set('v.value', appliedAmountNum.toFixed(2));
    var paidAmountApplied = component.find("paidAmountApplied");
    if (Array.isArray(paidAmountApplied)) paidAmountApplied = paidAmountApplied[0];
    if (paidAmountApplied) paidAmountApplied.set("v.value", appliedAmountNum);
    component.set("v.PaidAmountApplied", appliedAmountNum);

    console.log('✅ [WRITE] paidAmountApplied input ->', appliedAmountNum);
    console.log('✅ [WRITE] v.PaidAmountApplied ->', appliedAmountNum.toFixed(2));
    console.log('🟧 BRANCH: Advance present (or no schedule) — END');
      
    
      

}


    console.log('================= ✅ END: PAID_APPLIED =================');
}

                   
                  if(renderedFields[x].get('v.fieldName')==='ERP7__Sales_Invoice_Percentage__c'){
                        console.log('inhere1');
                        renderedFields[x].set('v.value',val);
                    }
                    if(renderedFields[x].get('v.fieldName')==='ERP7__Sales_Invoice_Tax_Percentage__c'){
                        console.log('inhere2');
                        renderedFields[x].set('v.value',0.00);
                    }
                }
                console.log('inhere3');
                var downPaymentAmtSales = component.find("downPaymentAmtSales");
                if(downPaymentAmtSales != undefined) downPaymentAmtSales.set("v.value",val);
                var downPaymentTax = component.find("downPaymentTax");

                console.log('inhere4');
                //alert(downPaymentTax);
                if(!component.get("v.disSchTax") && component.get("v.subTotal") > 0 && component.get("v.taxAmount")>0){
                    console.log('inhere5');
                    if(downPaymentTax!=undefined) downPaymentTax.set("v.value",parseFloat($A.get("$Label.c.Default_schedule_invoice_Tax")));
                    var val = parseFloat($A.get("$Label.c.Default_schedule_invoice_Tax"));
                    var renderedFields = component.find("inv_input_field");
                    var downPaymentAmtSales = component.find("downPaymentTax");
                    console.log('inhere6');
                    if(val!=null && val!=undefined && val!=''){
                        console.log('inhere7');
                        var invAmount = 0.00;
                        var TaxAmount = 0.00;
                        for(var  x in renderedFields){
                            if(renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c'){
                                // added this fix here, previously it was using some standerd percentage and wrong setting of the tax
                                var val1 = parseFloat(event.getSource().get("v.value")) || 0;
                                console.log("the tax amt ",component.get("v.taxAmount"));
                                //TaxAmount = component.get("v.taxAmount"); 
                                TaxAmount= ((component.get("v.taxAmount")*val1)/100).toFixed(2);
                                renderedFields[x].set('v.value',TaxAmount);
                                component.set("v.invTax", TaxAmount);
                                console.log('inv tax set here 1~>'+TaxAmount);
                            }
                            if(renderedFields[x].get('v.fieldName')==='ERP7__Sales_Invoice_Tax_Percentage__c'){
                                renderedFields[x].set('v.value',val);
                            }
                        }

                        for(var  x in renderedFields){
                            if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                                var val1 = parseFloat(event.getSource().get("v.value")) || 0;

                                console.log("the order amt 69",component.get("v.orderAmount"));
                                 var orderAmount = parseFloat(component.get("v.orderAmount")* val1 / 100) || 0;
    								console.log("Current orderAmount 12:", orderAmount);
                                var invoiceAmount = orderAmount; // parseFloat(component.get("v.subTotal"))+parseFloat(TaxAmount);
                                renderedFields[x].set('v.value',invoiceAmount);
                                component.set("v.InvAmount",invoiceAmount);
                                console.log('inv amt set here 2~>'+invoiceAmount);
                            }
                        }
                        var downPaymentTax = component.find("downPaymentTax");
                        if(downPaymentTax != undefined) downPaymentTax.set("v.value",val);
                        console.log('inhere8');
                    }
                    console.log('inhere9');
                }else{
                    console.log('inhere10');
                    for(var  x in renderedFields){
                        if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                             var val1 = parseFloat(event.getSource().get("v.value")) || 0;

                                console.log("the order amt 699",component.get("v.orderAmount"));
                                 var orderAmount = parseFloat(component.get("v.orderAmount")* val1 / 100) || 0;
    								console.log("Current orderAmount 12:", orderAmount);
                                var invoiceAmount = orderAmount; // parseFloat(component.get("v.subTotal"));
                            component.set("v.InvAmount",invoiceAmount);
                            console.log('inv amt set here 2~>'+invoiceAmount);
                        }
                    }
                    if(downPaymentTax != undefined) downPaymentTax.set("v.value",0.00);
                    
                 

                    
                    
                }
                
                  // Discount calculation (fixed, safe & clear)
            var val1 = parseFloat(event.getSource().get("v.value")) || 0;
            
            // --- Calculate discount amount ---
            var discountPct = parseFloat(component.get("v.discountAmount")) || 0;
            var discountAmt = (discountPct * val1 / 100);
            discountAmt = parseFloat(discountAmt.toFixed(2));
            
            console.log("Discount %:", discountPct, "| Discount Amt:", discountAmt);
            
            // --- Get current tax amount ---
            var taxPct = parseFloat(component.get("v.taxAmount")) || 0;
            console.log(" Tax %:", taxPct);
            
            // Discount only (Its not in funtion , its comemnted ) 
            if (discountAmt > 0 && taxPct === 0) {
                var invAmount = parseFloat(component.get("v.InvAmount")) || 0;
                console.log("Original InvAmount:", invAmount);
            
                var finalInvAmt = Math.max(invAmount - discountAmt, 0);
              //  component.set("v.InvAmount", finalInvAmt);
            
                console.log("Final invoice amount after discount:", finalInvAmt.toFixed(2));
            
            // Both discount and tax ---
            } else if (taxPct > 0) {
                console.log("Applying both discount and tax calculations...");
                console.log("Original tax %:", taxPct);
            
                var orderAmount = parseFloat(component.get("v.orderAmount")* val1 / 100) || 0;
                console.log("Current orderAmount:", orderAmount);
            
                
                component.set("v.InvAmount", orderAmount);
            
                console.log("Final invoice amount after discount & tax:", orderAmount.toFixed(2));
            
            // No discount or tax ---
            } else {
                console.log(" No discount or tax applied (amount ≤ 0).");
            }

                console.log('inhere11');
            }else{
                console.log('inhere12');
                var downPaymentAmtSales = component.find("downPaymentTax");
                if(downPaymentAmtSales!=undefined) downPaymentAmtSales.set("v.value",0.00);
                component.set("v.subTotal", 0.00);
                console.log('inhere13');
                for(var  x in renderedFields){
                    if(renderedFields[x].get('v.fieldName')==='ERP7__Paid_Amount_Applied__c'){
                        renderedFields[x].set('v.value',0);
                        var paidAmountApplied = component.find("paidAmountApplied");
                        if(paidAmountApplied != undefined) paidAmountApplied.set("v.value",0);
                        component.set("v.PaidAmountApplied", 0);
                        console.log('PaidAmountApplied 2: ',component.get("v.PaidAmountApplied"));
                    }
                    if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                        renderedFields[x].set('v.value',0);
                        component.set("v.subTotal", 0);
                        component.set("v.InvAmount",0);
                    }
                }
                $A.enqueueAction(component.get("c.getallinvoiceLI"));
            }
        } catch (e) {
    console.error('err raw ->', e);

    console.log('err.name:', e && e.name);
    console.log('err.message:', e && e.message);
    console.log('err.toString():', e && e.toString && e.toString());

    if (e && e.stack) {
        console.log('err.stack:\n' + e.stack);
    }

    try {
        console.log('err keys:', Object.keys(e));
        console.log('err own props:', Object.getOwnPropertyNames(e));
    } catch (_) {}

    try {
        console.log('err JSON:', JSON.stringify(e));
    } catch (_) {
        console.log('err JSON: <circular>');
    }
}

    },

    updateInvoicePercentage : function(component, event, helper) {
        var amount = component.get("v.subTotal");
        if(amount>0){
            var downPaymentAmtSales = component.find("downPaymentAmtSales");
            var percentage= (amount/component.get("v.invLineSubTotal"))*100;
            if(downPaymentAmtSales != undefined) downPaymentAmtSales.set("v.value",percentage.toFixed(2));
            if(amount>0){
                //downPaymentTax.set("v.value",parseFloat($A.get("$Label.c.Default_schedule_invoice_Tax")));
                var val = parseFloat($A.get("$Label.c.Default_schedule_invoice_Tax"));
                var renderedFields = component.find("inv_input_field");
                var downPaymentAmtSales = component.find("downPaymentTax");
                if(val!=null && val!=undefined && val!=''){
                    var invAmount = 0.00;
                    var TaxAmount = 0.00;
                    for(var  x in renderedFields){
                        if(renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c' && component.get("v.taxAmount")>0){
                            TaxAmount = ((component.get("v.subTotal")*val)/100).toFixed(2);
                            renderedFields[x].set('v.value',TaxAmount);
                            component.set("v.invTax", TaxAmount);
                        }
                        if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                            var invoiceAmount = parseFloat(component.get("v.subTotal"))+parseFloat(TaxAmount);
                            renderedFields[x].set('v.value',invoiceAmount);
                        }
                        if(renderedFields[x].get('v.fieldName')==='ERP7__Sales_Invoice_Tax_Percentage__c' && component.get("v.taxAmount")>0){
                            renderedFields[x].set('v.value',val);
                        }
                    }
                    var downPaymentTax = component.find("downPaymentTax");
                    if(component.get("v.taxAmount")>0 && downPaymentTax!=undefined) downPaymentTax.set("v.value",val);
                }
            }
        }else{
            var downPaymentAmtSales = component.find("downPaymentAmtSales");
            if(downPaymentAmtSales != undefined) downPaymentAmtSales.set("v.value",0.00);
            var renderedFields = component.find("inv_input_field");
            for(var  x in renderedFields){
                if(renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c'){
                    renderedFields[x].set('v.value',0.00);
                    component.set("v.invTax", 0.00);
                }
                if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                    renderedFields[x].set('v.value',0.00);
                }
                if(renderedFields[x].get('v.fieldName')==='ERP7__Sales_Invoice_Tax_Percentage__c'){
                    renderedFields[x].set('v.value',0.00);
                }
            }
        }
    },

    calculateIvoiceTaxAmount : function(component, event, helper) {

        var val = event.getSource().get("v.value");
        var renderedFields = component.find("inv_input_field");
        //var renderedFields = component.find("inv_input_field");
        var downPaymentAmtSales = component.find("downPaymentTax");
        if(val!=null && val!=undefined && val!=''){
            var invAmount = 0.00;
            var TaxAmount = 0.00;
            /*for(var  x in renderedFields){
                if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                    invAmount = renderedFields[x].get('v.value');
                }
            }*/

            for(var  x in renderedFields){
                if(renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c'){
                    TaxAmount = ((component.get("v.subTotal")*val)/100).toFixed(2);
                    renderedFields[x].set('v.value',TaxAmount);
                    component.set("v.invTax", TaxAmount);
                }
                if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c'){
                    //alert(component.get("v.subTotal"));
                    var invoiceAmount = parseFloat(component.get("v.subTotal"))+parseFloat(TaxAmount);
                    renderedFields[x].set('v.value',invoiceAmount);
                }
                if(renderedFields[x].get('v.fieldName')==='ERP7__Sales_Invoice_Tax_Percentage__c'){
                    renderedFields[x].set('v.value',val);
                }
            }
            var downPaymentTax = component.find("downPaymentTax");
            if(downPaymentTax!=undefined) downPaymentTax.set("v.value",val);
        }
    },

    closePopup : function(cmp){
        cmp.set("v.showToast",false);
    },


    setAmountApplied : function(component, event, helper) {
        try{

            var val = event.getSource().get("v.value");
            console.log('val : ',val);
            console.log('advancePaymentPaidAmount: ',component.get("v.advancePaymentPaidAmount"));
            console.log('TotalPaidAmountApplied: ',component.get("v.TotalPaidAmountApplied"));
            var remainingAmount = (component.get("v.advancePaymentPaidAmount") - component.get("v.TotalPaidAmountApplied"));
            console.log('remainingAmount 555555: ',remainingAmount);
            if(val > remainingAmount.toFixed(2)){//Moin added this .toFixed(2)
                console.log('in 4, just checking if this is the issue: ');
                component.set("v.showToast",true);
                component.set("v.message","Paid amount applied is greater than advance payment");
                component.set("v.PaidAmountApplied",remainingAmount.toFixed(2));
                var paidAmountApplied = component.find("paidAmountApplied");
                if(paidAmountApplied != undefined) paidAmountApplied.set("v.value",remainingAmount.toFixed(2));
                var renderedFields = component.find("inv_input_field");
                for(var  x in renderedFields){
                    if(renderedFields[x].get('v.fieldName')==='ERP7__Paid_Amount_Applied__c'){
                        renderedFields[x].set('v.value',remainingAmount.toFixed(2));
                    }
                }
                console.log('PaidAmountApplied 4: ',component.get("v.PaidAmountApplied"));
                window.setTimeout(
                    $A.getCallback(function() {
                        component.set("v.showToast",false);
                    }), 7000
                );
            }
            else{
                console.log('in 5: ');
                var paidAmountApplied = component.find("paidAmountApplied");
                if(paidAmountApplied != undefined) paidAmountApplied.set("v.value",val);
                component.set("v.PaidAmountApplied", val);
                console.log('PaidAmountApplied 3: ',component.get("v.PaidAmountApplied"));

                var renderedFields = component.find("inv_input_field");
                for(var  x in renderedFields){
                    if(renderedFields[x].get('v.fieldName')==='ERP7__Paid_Amount_Applied__c'){
                        if(val!=null && val!=undefined && val!=''){
                            renderedFields[x].set('v.value',val);
                        }else renderedFields[x].set('v.value',0.00);
                    }
                }
            }
        }catch(e){
            console.log('err',e);
        }
    }
})