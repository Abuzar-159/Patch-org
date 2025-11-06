({  
    
    display : function(component, event, helper) {
        helper.toggleHelperIn(component, event);
    },
    
    displayOut : function(component, event, helper) {
        helper.toggleHelperOut(component, event);
    },
    
    openOrderDropdown : function(cmp, event){
        $A.util.addClass(cmp.find('createOrderMenu'), 'slds-show');
    },
    
    closeOrderDropdown : function(cmp, event){
        $A.util.removeClass(cmp.find('createOrderMenu'), 'slds-show');
        cmp.popInit();
    },
    
    SOStatus: function(cmp, event) {
        var value = event.getSource().get("v.value");
        cmp.set("v.SalesOrder.ERP7__Status__c",value);
        window.scrollTo(0, 0);
        if(value == 'Cancelled'){
            //$('#myModalCancelled').modal('show');
            //document.getElementById('myModalCancelled').modal('show');
            $A.util.addClass(cmp.find("myModalCancelled"), 'slds-fade-in-open');
            $A.util.addClass(cmp.find("myModalCancelledBackdrop"), 'slds-fade-in-open');
        }
    },
    
    cancelReasonDone: function(cmp, event) {
        $A.util.removeClass(cmp.find("myModalCancelled"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("myModalCancelledBackdrop"), 'slds-fade-in-open');
    },
   
    CurrentSerialNumbers: function(cmp, event) {
        try{
            var count = event.getSource().get("v.name");
            var obj = cmp.get("v.itemWrapperListt"); 
            for(var x in obj){
                if(count == x) { 
                    cmp.set("v.SelectedProduct",obj[x]);
                    cmp.set("v.mySerialNos",obj[x].SerialNos);
                    cmp.set("v.myBatchNos",[]);
                    break;
                }
            }
            $A.util.addClass(cmp.find("myModalcurrentBatchSerial"),"slds-fade-in-open");
            $A.util.addClass(cmp.find("myModalcurrentBatchSerialBackdrop"),"slds-backdrop_open");
            //window.scrollTo(0, 0);
        }
        catch(err) {
            alert("Exception : "+err.message);
        }
    },
    
    CurrentBatchNumbers: function(cmp, event) {
        try{
            var count = event.getSource().get("v.name");
            var obj = cmp.get("v.itemWrapperListt"); 
            for(var x in obj){
                if(count == x) { 
                    cmp.set("v.SelectedProduct",obj[x]);
                    cmp.set("v.myBatchNos",obj[x].Batches);
                    cmp.set("v.mySerialNos",[]);
                    break;
                }
            }
            $A.util.addClass(cmp.find("myModalcurrentBatchSerial"),"slds-fade-in-open");
            $A.util.addClass(cmp.find("myModalcurrentBatchSerialBatchBackdrop"),"slds-backdrop_open");
            //window.scrollTo(0, 0);
        }
        catch(err) {
            alert("Exception : "+err.message);
        }
    },
    
    DeleteCoupon :function(cmp, event, helper){
        var CreditNote_Id = event.getSource().get("v.name");  
        
        var delAction = cmp.get("c.DeleteCreditNote");
        delAction.setParams({"CreditNoteId":CreditNote_Id});
        delAction.setCallback(this,function(response){
            var state= response.getState();
            if(state ==='SUCCESS'){
                if(response.getReturnValue() != ''){
                     cmp.set("v.exceptionError",response.getReturnValue());
                } else{
                    	cmp.set("v.proceed",true);
                        cmp.popInit();
                        
                    }
            }
        });
        $A.enqueueAction(delAction);
    },
    
    saveEstimateToOrder: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        //alert('UPS Service In '+SalesOrder[0].Id);
        if(SalesOrder[0].Id != undefined){
            cmp.set("v.UPSError", '');
        } else{
            cmp.set("v.UPSError", 'Please save the sales order');
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        
        if(SalesOrder[0].Id != undefined){
            var RecId = SalesOrder[0].Id;
            //alert('IN');
            var rateWrapperList = cmp.get("v.UPS_Services.Services");
            //alert(rateWrapperList.length);
            var rateWrapper = '';
            for(var x in rateWrapperList){
                if(rateWrapperList[x].Selected == true) rateWrapper = JSON.stringify(rateWrapperList[x]);
            }
            //alert(rateWrapper);
            var shipDate = cmp.get("v.UPS_Services.ShipmentDate");
            var AdditionalPercentage = cmp.get("v.UPS_Services.Additional");
            //alert(AdditionalPercentage);
            if(rateWrapper != ''){
                var action = cmp.get("c.UPSServiceSave");
                action.setParams({ 
                    soId: SalesOrder[0].Id,
                    rateWrapperSelected: rateWrapper,
                    shipDate: shipDate,
                    additionalPercent: AdditionalPercentage
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        cmp.set("v.proceed",true);
                        cmp.set("v.SON",RecId);
                        cmp.set("v.CON","");
                        cmp.set("v.CUST","");
                        $A.util.removeClass(cmp.find("myModalUPS"),"slds-fade-in-open");
                        $A.util.removeClass(cmp.find("myModalUPSBackdrop"),"slds-backdrop_open");
                        cmp.popInit();
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                });
                $A.enqueueAction(action);
            }
            
        } 
    },
    
    Services: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        //alert('UPS Service In '+SalesOrder[0].Id);
        if(SalesOrder[0].Id != undefined){
            cmp.set("v.UPSError", '');
        } else{
            cmp.set("v.UPSError", 'Please save the sales order');
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        if(SalesOrder[0].Id != undefined){
            //alert('IN');
            var packType = cmp.get("v.UPS_Services.PackageType");
            var packNo = cmp.get("v.UPS_Services.NoofPackage");
            var shipDate = cmp.get("v.UPS_Services.ShipmentDate");
            var action = cmp.get("c.UPSServices");
            action.setParams({ 
                soId: SalesOrder[0].Id,
                packType: packType,
                packNo: packNo,
                shipDate: shipDate
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") { 
                    if(response.getReturnValue().Services != undefined && response.getReturnValue().Services.length > 0){
                        response.getReturnValue().Services[0].Selected = true;
                    }
                    
                    cmp.set("v.UPS_Services",response.getReturnValue());
                    if(packType == null || packType == undefined || packType == '') cmp.find("packType").set("v.options", response.getReturnValue().PackageTypes);
                    cmp.set("v.UPS_Services.PackageType",response.getReturnValue().PackageType);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    
                }
            });
            $A.enqueueAction(action);
        } 
    },
    
    FedExServices: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        //alert('FedEx Service In '+SalesOrder[0].Id);
        if(SalesOrder[0].Id != undefined){
            cmp.set("v.FedExError", '');
        } else{
            cmp.set("v.FedExError", 'Please save the sales order');
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        if(SalesOrder[0].Id != undefined){
            //alert('IN');
            //alert("PackageType :",cmp.get("v.FEDEX_Services.PackageType"));
            //alert("NoofPackage :",cmp.get("v.FEDEX_Services.NoofPackage"));
            //alert("ShipmentDate :",cmp.get("v.FEDEX_Services.ShipmentDate"));
            var packType = cmp.get("v.FEDEX_Services.PackageType");
            var packNo = cmp.get("v.FEDEX_Services.NoofPackage");
            var shipDate = cmp.get("v.FEDEX_Services.ShipmentDate");
            var action = cmp.get("c.FedServices");
            action.setParams({ 
                soId: SalesOrder[0].Id,
                packType: packType,
                packNo: packNo,
                shipDate: shipDate
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                
                if (state === "SUCCESS") { 
                    if(response.getReturnValue().Services != undefined && response.getReturnValue().Services.length > 0){
                        response.getReturnValue().Services[0].Selected = true;
                    }
                    cmp.set("v.FEDEX_Services",response.getReturnValue());
                    if(packType == null) cmp.find("packType1").set("v.options", response.getReturnValue().PackageTypes);
                    cmp.set("v.FEDEX_Services.PackageType",response.getReturnValue().PackageType);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
                
            });
            $A.enqueueAction(action);
        } 
    },
    
    saveFedExEstimateToOrder: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        //alert('UPS Service In '+SalesOrder[0].Id);
        if(SalesOrder[0].Id != undefined){
            cmp.set("v.FedExError", '');
        } else{
            cmp.set("v.FedExError", 'Please save the sales order');
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        
        if(SalesOrder[0].Id != undefined){
            var RecId = SalesOrder[0].Id;
            var rateWrapperList = cmp.get("v.FEDEX_Services.Services");
            var rateWrapper = '';
            for(var x in rateWrapperList){
                if(rateWrapperList[x].Selected == true) rateWrapper = JSON.stringify(rateWrapperList[x]);
            }
            var shipDate = cmp.get("v.UPS_Services.ShipmentDate");
            var AdditionalPercentage = cmp.get("v.UPS_Services.Additional");
            
            if(rateWrapper != ''){
                var action = cmp.get("c.FedServicesSave");
                action.setParams({ 
                    soId: SalesOrder[0].Id,
                    rateWrapperSelected: rateWrapper, 
                    additionalPercent: AdditionalPercentage
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        cmp.set("v.SON",RecId);
                        cmp.set("v.CON","");
                        cmp.set("v.CUST",""); 
                        cmp.set("v.proceed",true);
                        $A.util.removeClass(cmp.find("myModalFedEx"),"slds-fade-in-open");
                        $A.util.removeClass(cmp.find("myModalFedExBackdrop"),"slds-backdrop_open");
                        cmp.popInit();
                        
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                });
                $A.enqueueAction(action);
            }
        } 
    },
    

    DHL_Services: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        
        if(SalesOrder[0].Id != undefined){
            cmp.set("v.DHLError", '');
        } else{
            cmp.set("v.DHLError", 'Please save the sales order');
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        if(SalesOrder[0].Id != undefined){
            var packType = cmp.get("v.DHL_Services.PackageType");
            var packNo = cmp.get("v.DHL_Services.NoofPackage");
            var shipDate = cmp.get("v.DHL_Services.ShipmentDate");
            var action = cmp.get("c.DHLServices");
            action.setParams({  
                soId: SalesOrder[0].Id,
                packType: packType,
                packNo: packNo,
                shipDate: shipDate
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    if(response.getReturnValue().Services != undefined && response.getReturnValue().Services.length > 0){
                        response.getReturnValue().Services[0].Selected = true;
                    }
                    cmp.set("v.DHL_Services",response.getReturnValue());
                    if(packType == null) cmp.find("packType2").set("v.options", response.getReturnValue().PackageTypes);
                    cmp.set("v.DHL_Services.PackageType",response.getReturnValue().PackageType);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
                
            });
            $A.enqueueAction(action);
        } 
        
    },
    
    
    
    saveDHLEstimateToOrder: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        
        if(SalesOrder[0].Id != undefined){
            cmp.set("v.DHLError", '');
        } else{
            cmp.set("v.DHLError", 'Please save the sales order');
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        
        if(SalesOrder[0].Id != undefined){
            var RecId = SalesOrder[0].Id;
            var rateWrapperList = cmp.get("v.DHL_Services.Services");
            var rateWrapper = '';
            for(var x in rateWrapperList){
                if(rateWrapperList[x].Selected == true) rateWrapper = JSON.stringify(rateWrapperList[x]);
            }
            var shipDate = cmp.get("v.DHL_Services.ShipmentDate");
            var AdditionalPercentage = cmp.get("v.DHL_Services.Additional");
            if(rateWrapper != ''){ 
                var action = cmp.get("c.DhlServicesSave");
                action.setParams({ 
                    soId: SalesOrder[0].Id,
                    rateWrapperSelected: rateWrapper,
                    additionalPercent: AdditionalPercentage
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //$('#myModalDHL').modal('hide');
                        $A.util.addClass(cmp.find('mainSpin'),'hide');
                        cmp.set("v.SON",RecId);
                        cmp.set("v.CON","");
                        cmp.set("v.CUST",""); 
                        cmp.set("v.proceed",true);
                        $A.util.removeClass(cmp.find("myModalDHL"),"slds-fade-in-open");
                        $A.util.removeClass(cmp.find("myModalDHLBackdrop"),"slds-backdrop_open");
                        cmp.popInit();
                        
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                });
                $A.enqueueAction(action);
            }
        } 
    },

 


    CashPayment: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var Customer = new Array(cmp.get("v.Customer"));
        var custsize = Customer.length;
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        var sosize = SalesOrder.length;
        var FinalDue = cmp.get("v.finalDue");
        
        var Invoice = cmp.get("v.Invoice");
        var Paymt = cmp.get("v.Payment");
        if(Invoice != undefined && Invoice.Id != undefined) Paymt.ERP7__Invoice__c = Invoice.Id;
        
        var Payments = JSON.stringify(Paymt);
        var Payment = new Array(Paymt);
        var paymentsize = Payment.length;
        var Proceed = false;
        var RecId = SalesOrder[0].Id;
        
        if(SalesOrder[0].Id != undefined && Customer.length > 0 && SalesOrder.length > 0 && Payment.length > 0 && FinalDue > 0 && Payment[0].ERP7__Total_Amount__c > 0 && Payment[0].ERP7__Total_Amount__c <= FinalDue){
            Proceed = true;
            cmp.set("v.CashError", '');
        } else{
            cmp.set("v.CashError", 'Invalid Details');
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        //alert('Proceed : '+Proceed);
        
        if(Proceed == true){
            //alert('Cash Payment In');
            var action = cmp.get("c.CreateCashPayment");
            action.setParams({ 
                SalesOrder2Creates1: JSON.stringify(SalesOrder),
                Payments: Payments
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    //$('#myModalCash').modal('hide');
                    cmp.set("v.proceed",true);
                    cmp.set("v.SON",RecId);
                    cmp.set("v.CON","");
                    cmp.set("v.CUST","");
                    $A.util.removeClass(cmp.find("myModalCash"),"slds-fade-in-open");
                    $A.util.removeClass(cmp.find("myModalCashBackdrop"),"slds-backdrop_open");
                    cmp.popInit();
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    BankPayment: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var Customer = new Array(cmp.get("v.Customer"));
        var custsize = Customer.length;
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        var sosize = SalesOrder.length;
        var FinalDue = cmp.get("v.finalDue");
        
        var Invoice = cmp.get("v.Invoice");
        var Paymt = cmp.get("v.Payment");
        if(Invoice != undefined && Invoice.Id != undefined) Paymt.ERP7__Invoice__c = Invoice.Id;
        
        var Payments = JSON.stringify(Paymt);
        var Payment = new Array(Paymt);
        var paymentsize = Payment.length;
        var Proceed = false;
        var RecId = SalesOrder[0].Id;
        //alert(Payment[0].ERP7__Bank__c);
        //alert(Payment[0].ERP7__Reference_Cheque_No__c);
        //alert(Payment[0].ERP7__Account_Number__c);
        //alert(Payment[0].ERP7__Account_Holder_Name__c);
        //if(Payment[0].ERP7__Bank__c != '' && Payment[0].ERP7__Reference_Cheque_No__c != '' && Payment[0].ERP7__Account_Number__c != '' && Payment[0].ERP7__Account_Holder_Name__c != '' && Payment[0].ERP7__Bank__c != undefined && Payment[0].ERP7__Reference_Cheque_No__c != undefined && Payment[0].ERP7__Account_Number__c != undefined && Payment[0].ERP7__Account_Holder_Name__c != undefined && SalesOrder[0].Id != undefined && Customer.length > 0 && SalesOrder.length > 0 && Payment.length > 0 && FinalDue > 0 && Payment[0].ERP7__Total_Amount__c > 0 && Payment[0].ERP7__Total_Amount__c <= FinalDue){
        if(Payment[0].ERP7__Reference_Cheque_No__c != '' && Payment[0].ERP7__Reference_Cheque_No__c != undefined && SalesOrder[0].Id != undefined && Customer.length > 0 && SalesOrder.length > 0 && Payment.length > 0 && FinalDue > 0 && Payment[0].ERP7__Total_Amount__c > 0 && Payment[0].ERP7__Total_Amount__c <= FinalDue){
        	Proceed = true;
            cmp.set("v.BankError", '');
        } else{
            cmp.set("v.BankError", 'Invalid Details');
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        //alert('Proceed : '+Proceed);
        
        if(Proceed == true){
            //alert('Bank Payment In');
            var action = cmp.get("c.CreateBankPayment");
            action.setParams({ 
                SalesOrder2Creates1: JSON.stringify(SalesOrder),
                Payments: Payments
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    cmp.set("v.fieldError",'');
                    //$('#myModalBank').modal('hide');
                    cmp.set("v.SON",RecId);
                    cmp.set("v.CON","");
                    cmp.set("v.CUST",""); 
                    cmp.set("v.proceed",true);
                    $A.util.removeClass(cmp.find("myModalBank"),"slds-fade-in-open");
                    $A.util.removeClass(cmp.find("myModalBankBackdrop"),"slds-backdrop_open");
                    cmp.popInit();
                    
                }else if(response.getState() === "ERROR") {
                    //$A.util.removeClass(cmp.find("myModalBank"),"slds-fade-in-open");
                    //$A.util.removeClass(cmp.find("myModalBankBackdrop"),"slds-backdrop_open");
                    var errors = response.getError();
                    var errlist= [];
                    if(errors[0] && errors[0].fieldErrors) {
                        var obj = errors[0].fieldErrors;
                        for(var fieldname in obj)
                        console.log('err Message '+obj[fieldname][0].message);
                        errlist.push(obj[fieldname][0].message);  
                    }
                    cmp.set("v.fieldError",errlist.toString());
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    CardPayment: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        
        
            var Customer = new Array(cmp.get("v.Customer"));
            var custsize = Customer.length;
            var SalesOrder = new Array(cmp.get("v.SalesOrder"));
            var sosize = SalesOrder.length;
            var FinalDue = cmp.get("v.finalDue");
            var CVV = cmp.get("v.CVV");
            
            var Invoice = cmp.get("v.Invoiced");
            var Paymt = cmp.get("v.Payment");
            if(Invoice != undefined && Invoice.Id != undefined) Paymt.ERP7__Invoice__c = Invoice.Id;
            
            var Payments = JSON.stringify(Paymt);
            var Payment = new Array(Paymt);
            
            var PaymentMethods = JSON.stringify(cmp.get("v.PaymentMethod"));
            var PaymentMethod = new Array(cmp.get("v.PaymentMethod"));
            var paymentsize = Payment.length;
            var Proceed = false;
            var RecId = SalesOrder[0].Id;
       
            if(PaymentMethod[0].ERP7__Name_on_Card__c != undefined && PaymentMethod[0].ERP7__CardType__c != undefined && PaymentMethod[0].ERP7__Card_Number__c != null && PaymentMethod[0].ERP7__Card_Number__c != undefined && PaymentMethod[0].ERP7__Card_Expiration_Month__c != undefined && PaymentMethod[0].ERP7__Card_Expiration_Year__c != undefined && PaymentMethod[0].ERP7__Name_on_Card__c != undefined && SalesOrder[0].Id != undefined && Customer.length > 0 && SalesOrder.length > 0 && Payment.length > 0 && FinalDue > 0 && Payment[0].ERP7__Total_Amount__c > 0 && Payment[0].ERP7__Total_Amount__c <= FinalDue){
                Proceed = true;
                cmp.set("v.CardError", '');
            } else {
                cmp.set("v.CardError", "Invalid Details");
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
            //alert('Proceed : '+Proceed);
            
            if(Proceed == true){
                /*Multiple Invoice Payment
                 * var invList=cmp.get('v.invList');
               
                var selInvList=cmp.get('v.selInvList');
                if(invList.length > 1 && selInvList.length ==0){
                    cmp.set("v.CardError", "Please Select Invoice");
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    return;
                }
              */
                
                    
                    var action = cmp.get("c.CreateCardPaymentUpdat");
                    action.setParams({ 
                        SalesOrder2Creates1: JSON.stringify(SalesOrder),
                        Payments: Payments,
                        PaymentMethods: PaymentMethods,
                        CVV: CVV, 
                        billingAddress1 : JSON.stringify(cmp.get("v.BillAddress")),
                        orgId : cmp.get("v.orgId")
                        
                    });
               		//selInvList : selInvList  //Parameter for Multiple Invoice payment
                    
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        //alert(response.getReturnValue());
                        if (state === "SUCCESS") {
                            if(response.getReturnValue() == ''){
                                //$('#myModalCard').modal('hide');
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                cmp.set("v.SON",RecId);
                                cmp.set("v.CON","");
                                cmp.set("v.CUST","");
                                cmp.set("v.proceed",true);
                                $A.util.removeClass(cmp.find("myModalCard"),"slds-fade-in-open");
                                $A.util.removeClass(cmp.find("myModalCardBackdrop"),"slds-backdrop_open");
                                cmp.popInit();
                                
                            } else{
                                //$A.util.removeClass(cmp.find("myModalCard"),"slds-fade-in-open");
                                //$A.util.removeClass(cmp.find("myModalCardBackdrop"),"slds-fade-in-open");
                                cmp.set("v.CardError", response.getReturnValue()); 
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                
                            }
                        }
                    });
                    $A.enqueueAction(action);
                //}
                
                //alert('Card Payment In');
                
            
        }
    },
    
    NavRecord : function (component, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    BOrder : function(cmp, event) {
        var BO = cmp.get("v.SalesOrder.ERP7__Is_Back_Order__c");
        var PO = false;
        if(BO == true) cmp.set("v.SalesOrder.ERP7__Is_Pre_Order__c",PO);
    },
    
    POrder : function(cmp, event) {
        var PO = cmp.get("v.SalesOrder.ERP7__Is_Pre_Order__c");
        var BO = false;
        if(PO == true) cmp.set("v.SalesOrder.ERP7__Is_Back_Order__c",BO);
    },
    
    SubscribeOrder : function(cmp, event) {
        var Contact = new Array(cmp.get("v.Contact"));
        var consize = Contact.length;
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        var sosize = SalesOrder.length;
        var sop = cmp.get("v.SOP");
        
        if(Contact.length > 0 && sop != '' && SalesOrder[0].Name != '' && SalesOrder[0].Name != undefined && SalesOrder[0].Name != null){
            var URLsubscribe = '/apex/ERP7__AddSubscription?cust='+Contact[0].ERP7__Contact_Numer__c+'&profile='+sop+'&oid='+SalesOrder[0].Id;
            window.open(URLsubscribe,'_blank');
        }
    },
    
    ProcessLoyalty : function(cmp, event) {
        
        var customerCreditLimit = cmp.get("v.customerCreditLimit");
        var LoyaltyPoint2Use = cmp.get("v.LoyaltyPoint2Use");
        var FinalDue = cmp.get("v.finalDue");
        
        var Customer = new Array(cmp.get("v.Customer"));
        var custsize = Customer.length;
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        var sosize = SalesOrder.length;
        var TotalDue = cmp.get("v.totalDue");
        var LoyaltyAmount = cmp.get("v.loyaltyAmount");
        var LoyaltyPoints = cmp.get("v.loyaltyPoints");
        
        if(Customer.length > 0 && SalesOrder.length > 0 && customerCreditLimit > 0 && FinalDue > 0 && LoyaltyPoint2Use > 0 && LoyaltyPoint2Use <= customerCreditLimit){
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.loyaltyProcessing");
            action.setParams({ 
                SalesOrder2Creates1: JSON.stringify(SalesOrder),
                Customers1: JSON.stringify(Customer),
                FinalDues: FinalDue,
                TotalDues: TotalDue,
                LoyaltyAmounts: LoyaltyAmount,
                LoyaltyPoint_s: LoyaltyPoints,
                customerCreditLimit: LoyaltyPoint2Use
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                   
                    cmp.set("v.finalDue",response.getReturnValue().FinalDue);
                    cmp.set("v.totalDue",response.getReturnValue().TotalDue);
                    cmp.set("v.loyaltyAmount",response.getReturnValue().loyaltyAmount);
                    cmp.set("v.loyaltyPoints",response.getReturnValue().loyaltyPoints);
                    cmp.set("v.customerCreditLimit",response.getReturnValue().customerCreditLimit);
                    cmp.set("v.LoyaltyError", "");
                    $A.util.removeClass(cmp.find("myModalLoyalty"),"slds-fade-in-open");
                    $A.util.removeClass(cmp.find("myModalLoyaltyBackdrop"),"slds-backdrop_open");
                   
                    cmp.saveMethod();
                }   else {
                    //$A.util.removeClass(cmp.find("myModalLoyalty"),"slds-fade-in-open");
                    //$A.util.removeClass(cmp.find("myModalLoyaltyBackdrop"),"slds-backdrop_open");
                    cmp.set("v.LoyaltyError", response.getReturnValue()); 
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        } else {
            //$A.util.removeClass(cmp.find("myModalLoyalty"),"slds-fade-in-open");
            //$A.util.removeClass(cmp.find("myModalLoyaltyBackdrop"),"slds-backdrop_open");
            cmp.set("v.LoyaltyError", "Invalid Details");
        }
    },
    
    ProcessCredit : function(cmp, event) {
        var CreditAmount = cmp.get("v.Customer.ERP7__Available_Credit_Balance__c");
        var CreditAmount2Use = cmp.get("v.CreditAmount2Use");
        var FinalDue = cmp.get("v.finalDue");
        var Customer = new Array(cmp.get("v.Customer"));
        var custsize = Customer.length;
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        var Invoice = new Array(cmp.get("v.Invoice"));
        var sosize = SalesOrder.length;
        var TotalDue = cmp.get("v.totalDue");
        //alert('CreditAmount : '+CreditAmount);
        //alert('FinalDue : '+FinalDue);
        //alert('TotalDue : '+TotalDue);
        //alert('CreditAmount2Use : '+CreditAmount2Use);
        if(Customer.length > 0 && SalesOrder.length > 0 && Invoice.length > 0 && CreditAmount > 0 && FinalDue > 0 && CreditAmount2Use > 0 && CreditAmount2Use <= CreditAmount && CreditAmount2Use <= FinalDue){
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.CreditProcessing");
            action.setParams({ 
                SalesOrder2Creates1: JSON.stringify(SalesOrder),
                Invoices1: JSON.stringify(Invoice),
                Customers1: JSON.stringify(Customer),
                FinalDues: FinalDue,
                TotalDues: TotalDue,
                CreditAmounts: CreditAmount,
                CreditAmount2Uses: CreditAmount2Use
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    if(response.getReturnValue().Error == false){
                        cmp.set("v.CreditError",'');
                        //$('#myModalapplycredit').modal('hide');
                        var sonId = response.getReturnValue().Value;
                        //alert(sonId);
                        cmp.set("v.proceed",true);
                        cmp.set("v.SON",sonId);
                        //cmp.set("v.CreditAmount2Use",0);
                        $A.util.removeClass(cmp.find("myModalApplyCred"),"slds-fade-in-open");
                        $A.util.removeClass(cmp.find("myModalApplyBackdrop"),"slds-backdrop_open");
                        cmp.popInit();
                        
                    } else if(response.getReturnValue().Error == true){
                        //alert(response.getReturnValue().errorMsg);
                        //$A.util.removeClass(cmp.find("myModalApplyCred"),"slds-fade-in-open");
                        //$A.util.removeClass(cmp.find("myModalCancelledBackdrop"),"slds-backdrop_open");
                        cmp.set("v.CreditError",response.getReturnValue().errorMsg);
                    }    
                } 
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");                
            });
            $A.enqueueAction(action);
        } else {
            cmp.set("v.CreditError", "Invalid Credit Amount");
            //$A.util.removeClass(cmp.find("myModalApplyCred"),"slds-fade-in-open");
            //$A.util.removeClass(cmp.find("myModalCancelledBackdrop"),"slds-backdrop_open");
        }
    },
    
    OpenInvoice : function(cmp, event) {
        var Contact = new Array(cmp.get("v.Contact"));
        var consize = Contact.length;
        var Invoice = new Array(cmp.get("v.Invoice"));
        var invsize = Invoice.length;
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        if(SalesOrder[0].Name != '' && SalesOrder[0].Name != undefined && SalesOrder[0].Name != null ){
            var URL_INV ='';
            if(Contact[0].ERP7__Contact_Numer__c != null && Contact[0].ERP7__Contact_Numer__c!= undefined && Contact[0].ERP7__Contact_Numer__c!= '' ){
                 URL_INV = $A.get("$Label.c.Invoice_Document");
            	URL_INV = URL_INV + 'custId=' + Contact[0].ERP7__Contact_Numer__c+'&name='+Invoice[0].Name;
                //URL_INV = '/apex/ERP7__Invoice?custId='+Contact[0].ERP7__Contact_Numer__c+'&name='+Invoice[0].Name;
            }else{
                URL_INV = $A.get("$Label.c.Invoice_Document");
            	URL_INV = 'custId=' + Contact[0].Id+'&name='+Invoice[0].Name;
                //URL_INV = '/apex/ERP7__Invoice?custId='+Contact[0].Id+'&name='+Invoice[0].Name;  
            }
            window.open(URL_INV,'_blank');
        }
    },
        
    OpenOrder : function(cmp, event) {
        var Contact = new Array(cmp.get("v.Contact"));
        var consize = Contact.length;
        var Invoice = new Array(cmp.get("v.Invoice"));
        var invsize = Invoice.length;
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        if(SalesOrder[0].Name != '' && SalesOrder[0].Name != undefined && SalesOrder[0].Name != null ){
            var URL_INV ='';
            URL_INV = $A.get("$Label.c.Sales_Order_Document");
            URL_INV = URL_INV + 'custId='+Contact[0].Id+'&Id='+SalesOrder[0].Id;
            //URL_INV = '/apex/ERP7__SalesOrderDocument?custId='+Contact[0].Id+'&Id='+SalesOrder[0].Id;  
            window.open(URL_INV,'_blank');
        }
    },
    
    RMA : function(cmp, event) {
        var Contact = new Array(cmp.get("v.Contact"));
        var consize = Contact.length;
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        var sosize = SalesOrder.length;
        if(Contact.length > 0 && SalesOrder.length > 0){
            if(SalesOrder[0].ERP7__Is_Closed__c == true){
                //var URL_RMA = '/apex/ERP7__ProcessReturnPage?con='+Contact[0].ERP7__Contact_Numer__c+'&oid='+SalesOrder[0].Name;
                var URL_RMA = '/apex/ERP7__RMA?soId='+SalesOrder[0].Id;
                window.open(URL_RMA,'_blank');
            }
        }
    },
    
    CreateAccount : function(cmp, event) {
        var Customers = new Array(cmp.get("v.NewCustomer"));
        var AccProfile2 = cmp.get("v.AccProfile2");
        var AccTax2 = cmp.get("v.AccTax2");
        if(AccProfile2 != null) Customers[0].ERP7__Account_Profile__c = AccProfile2.Id;
        if(AccTax2 != null) Customers[0].ERP7__VAT__c = AccTax2.Id;  
        var error = false; 
        if(Customers[0].Name == undefined || Customers[0].ERP7__Account_Profile__c == undefined){
            cmp.set("v.NewAccountError", "Required fields are missing");
            error = true;
        }
        if(!error && Customers[0].ERP7__Email__c != undefined && Customers[0].ERP7__Email__c != null && Customers[0].ERP7__Email__c != ''){
            var x = Customers[0].ERP7__Email__c;
            var atpos = x.indexOf("@");
            var dotpos = x.lastIndexOf(".");
            if (atpos<1 || dotpos<atpos+2 || dotpos+2>=x.length) {
                error = true;
                cmp.set("v.NewAccountError", "Please enter a valid email address");
            }
        } 
        
        if(!error && Customers[0].Website != undefined && Customers[0].Website != null && Customers[0].Website != ''){
            var url = Customers[0].Website;
            var regex = new RegExp("^(http[s]?:\\/\\/(www\\.)?|ftp:\\/\\/(www\\.)?|www\\.){1}([0-9A-Za-z-\\.@:%_\+~#=]+)+((\\.[a-zA-Z]{2,3})+)(/(.)*)?(\\?(.)*)?");
            if(!regex.test(url)) {
                error = true;
                cmp.set("v.NewAccountError", "Please enter a valid Website");
            } 
        } 
        if(!error && Customers[0].Phone != undefined && Customers[0].Phone != null && Customers[0].Phone != ''){
            var phone = Customers[0].Phone;
            var regex = /^[(]{0,1}[0-9]{3}[)]{0,1}[-\s\.]{0,1}[0-9]{3}[-\s\.]{0,1}[0-9]{4}$/;
            /*
                (123) 456-7890
                123-456-7890
                123.456.7890
                1234567890
            */
            
            if(!regex.test(phone)) {
                error = true;
                cmp.set("v.NewAccountError", "Please enter a valid phone number");
            } 
        } 
         if(!error) {
             var Cust = '';
             var action = cmp.get("c.CreateNewCustomers");
             action.setParams({ 
                 Customers1: JSON.stringify(Customers)
             });
             
             action.setCallback(this, function(response) {
                 var state = response.getState();
                
                 if (state === "SUCCESS") {
                    if(response.getReturnValue().Error != true) Cust = response.getReturnValue().Value;
                    if(Cust != null && Cust != ""){
                         try{ 
                             $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                             cmp.set("v.proceed",false);
                             cmp.set("v.SON","");
                             cmp.set("v.CON","");
                             cmp.set("v.CUST",Cust);
                             cmp.set("v.Customer.Id",Cust);
                             cmp.popInit();
                             cmp.set("v.NewAccountError","");
                             cmp.set("v.NewCustomer.Name","");
                             cmp.set("v.NewCustomer.AccountNumber","");
                             cmp.set("v.NewCustomer.ERP7__Email__c","");
                             cmp.set("v.NewCustomer.Phone","");
                             cmp.set("v.NewCustomer.Fax","");
                             cmp.set("v.NewCustomer.ERP7__Company__c","");
                             cmp.set("v.NewCustomer.Website","");
                             cmp.set("v.NewCustomer.ERP7__VAT_registration_number__c","");
                             cmp.set("v.NewCustomer.ERP7__Is_Person_Account__c","");
                             cmp.set("v.NewCustomer.Description","");
                         }catch(err){
                            //window.location.href = '/apex/ERP7__POSLC?Cust='+Cust;
                        }
                    } else {
                        cmp.set("v.NewAccountError", response.getReturnValue().errorMsg);
                    }
                 }
                 $A.util.removeClass(cmp.find("myModalAcc"),"slds-fade-in-open");
                 $A.util.removeClass(cmp.find("myModalAccBackdrop"),"slds-backdrop_open");
             });
             $A.enqueueAction(action);
         } 
         
     },
    
    CreateCon : function(cmp, event) {
        var Conts = new Array(cmp.get("v.NewContact"));
        var NewCust = cmp.get("v.NewCust");
        var error = false;
        if(NewCust.Id != undefined) Conts[0].AccountId = NewCust.Id;
        if(NewCust.Id == undefined || Conts[0].AccountId == undefined || Conts[0].FirstName == undefined || Conts[0].FirstName == null || Conts[0].FirstName == '' || Conts[0].LastName == undefined || Conts[0].LastName == null || Conts[0].LastName == ''){
            cmp.set("v.NewContactError", "Required fields are missing");
            error = true; 
        }
        if(!error && Conts[0].Email != undefined && Conts[0].Email != null && Conts[0].Email != ''){
            var x = Conts[0].Email;
            var atpos = x.indexOf("@");
            var dotpos = x.lastIndexOf(".");
            if (atpos<1 || dotpos<atpos+2 || dotpos+2>=x.length) {
                error = true;
                cmp.set("v.NewContactError", "Please enter a valid email address");
            }
        } 
        if(!error && Conts[0].Phone != undefined && Conts[0].Phone != null && Conts[0].Phone != ''){
            var phone = Conts[0].Phone;
            var regex = /^[(]{0,1}[0-9]{3}[)]{0,1}[-\s\.]{0,1}[0-9]{3}[-\s\.]{0,1}[0-9]{4}$/;
            if(!regex.test(phone)) {
                error = true;
                cmp.set("v.NewContactError", "Please enter a valid phone number");
            } 
        } 
        if(!error) {
            var action = cmp.get("c.CreateNewConts");
            action.setParams({ 
                Cons1: JSON.stringify(Conts)
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //cmp.set("v.RecentlyViewedList", response.getReturnValue());
                    try{ 
                        if(cmp.get("v.proceed")){
                            if(response.getReturnValue().Error != true){
                                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                                cmp.set("v.SON","");
                                cmp.set("v.CON",response.getReturnValue().Value);
                                cmp.set("v.CUST","");
                                cmp.set("v.Contact.Id",response.getReturnValue().Value);
                                cmp.popInit();
                                cmp.set("v.NewContactError","");
                                cmp.set("v.NewContact.FirstName","");
                                cmp.set("v.NewContact.LastName","");
                                cmp.set("v.NewContact.ERP7__Company__c","");
                                cmp.set("v.NewContact.Phone","");
                                cmp.set("v.NewContact.ERP7__Primary__c",false);
                                $A.util.removeClass(cmp.find("myModalCon"),"slds-fade-in-open");
                                $A.util.removeClass(cmp.find("myModalConBackdrop"),"slds-backdrop_open");
                            } else{
                                cmp.set("v.NewContactError", response.getReturnValue().errorMsg);
                            }
                        }
                    }catch(err){}
                }
                
            });
            $A.enqueueAction(action);
        }
    },
    
    CreateAddress : function(cmp, event) {
        var NewAddres = new Array(cmp.get("v.NewAddress"));
        var NewCust = cmp.get("v.NewCust");
        if(NewCust.Id != undefined) NewAddres[0].ERP7__Customer__c = NewCust.Id;
        var NewCon = cmp.get("v.NewCon");
        if(NewCon.Id != undefined) NewAddres[0].ERP7__Contact__c = NewCon.Id;
        var Country = cmp.get("v.objDetail.ERP7__Country__c");
        var State = cmp.get("v.objDetail.ERP7__State__c");
        var error = false;
        
        if(NewAddres[0].ERP7__Customer__c == undefined || NewAddres[0].ERP7__Contact__c == undefined || NewAddres[0].ERP7__Address_Line1__c == undefined || NewAddres[0].ERP7__Address_Line1__c == null || NewAddres[0].ERP7__Address_Line1__c == '' || NewAddres[0].ERP7__City__c == undefined || NewAddres[0].ERP7__City__c == null || NewAddres[0].ERP7__City__c == '' || Country == undefined || Country == '--- None ---' || NewAddres[0].ERP7__Postal_Code__c == undefined || NewAddres[0].ERP7__Postal_Code__c == null || NewAddres[0].ERP7__Postal_Code__c == ''){
            error = true;
            cmp.set("v.NewAddressError", "Required fields are missing");
        }
        if(!error && NewAddres[0].ERP7__Customer__c != undefined && NewAddres[0].ERP7__Contact__c != undefined && NewAddres[0].ERP7__Address_Line1__c != undefined && NewAddres[0].ERP7__City__c != undefined  && Country != undefined  && NewAddres[0].ERP7__Postal_Code__c != undefined){
            var action = cmp.get("c.SaveNewAddress");
            action.setParams({ 
                NewAddres1: JSON.stringify(NewAddres),
                State: State,
                Country: Country
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.exceptionError",'');
                    //cmp.set("v.RecentlyViewedList", response.getReturnValue());
                    var ad = JSON.stringify(response.getReturnValue());
                    var acc = NewCust.Id;
                    var pageSubscription = cmp.get("v.pageSubscription");
                    var bAdd = JSON.stringify(cmp.get("v.bAdd"));
                    var sAdd = JSON.stringify(cmp.get("v.sAdd"));
                    var bAddList = cmp.find("bAdd").get("v.options");
                    var sAddList = cmp.find("sAdd").get("v.options");
                    if(acc != null && response.getReturnValue().Id != null && acc != undefined && response.getReturnValue().Id != undefined && response.getReturnValue().ERP7__Customer__c == acc){
                        if(response.getReturnValue().ERP7__Is_Billing_Address__c == true){
                            bAddList.push({
                                value: response.getReturnValue().Id,
                                label: response.getReturnValue().ERP7__Postal_Code__c+','+response.getReturnValue().ERP7__Address_Line1__c, 
                                selected: false
                            });
                            //cmp.set("v.bAdd",response.getReturnValue().Id)
                            cmp.find("bAdd").set("v.options", bAddList);
                            var baddr = response.getReturnValue();
                            if(bAddList.length == 1){
                               var SA = ''
                                if(baddr.ERP7__Address_Line1__c != undefined && baddr.ERP7__Address_Line1__c != "") SA += baddr.ERP7__Address_Line1__c+', ';
                                if(baddr.ERP7__Address_Line2__c != undefined && baddr.ERP7__Address_Line2__c != "") SA += baddr.ERP7__Address_Line2__c+', ';
                                if(baddr.ERP7__Address_Line3__c != undefined && baddr.ERP7__Address_Line3__c != "") SA += baddr.ERP7__Address_Line3__c+', ';
                                if(baddr.ERP7__city__c != undefined && baddr.ERP7__City__c != "") SA += baddr.ERP7__City__c+', ';
                                if(baddr.ERP7__State__c != undefined && baddr.ERP7__State__c != "") SA += baddr.ERP7__State__c+', ';
                                if(baddr.ERP7__Postal_Code__c != undefined && baddr.ERP7__Postal_Code__c != "") SA += baddr.ERP7__Postal_Code__c+', ';
                                if(baddr.ERP7__Country__c != undefined && baddr.ERP7__Country__c != "") SA += baddr.ERP7__Country__c;
                                cmp.set("v.pageSubscription.ERP7__Bill_To_Address__c",SA);
                                
                            }
                        } 
                        if(response.getReturnValue().ERP7__Is_Shipping_Address__c == true){
                            //alert('sAddList : '+sAddList.length);
                            sAddList.push({
                                value: response.getReturnValue().Id,
                                label: response.getReturnValue().ERP7__Postal_Code__c+','+response.getReturnValue().ERP7__Address_Line1__c,
                                selected: false
                            });
                            cmp.find("sAdd").set("v.options", sAddList);
                            //cmp.set("v.sAdd",response.getReturnValue().Id)
                            var saddr = response.getReturnValue();
                            var saddrSTR = JSON.stringify(saddr);
                            //alert(saddrSTR);
                            if(sAddList.length == 1){
                                var SA = ''
                                if(saddr.ERP7__Address_Line1__c != undefined && saddr.ERP7__Address_Line1__c != "") SA += saddr.ERP7__Address_Line1__c+', ';
                                if(saddr.ERP7__Address_Line2__c != undefined && saddr.ERP7__Address_Line2__c != "") SA += saddr.ERP7__Address_Line2__c+', ';
                                if(saddr.ERP7__Address_Line3__c != undefined && saddr.ERP7__Address_Line3__c != "") SA += saddr.ERP7__Address_Line3__c+', ';
                                if(saddr.ERP7__city__c != undefined && saddr.ERP7__City__c != "") SA += saddr.ERP7__City__c+', ';
                                if(saddr.ERP7__State__c != undefined && saddr.ERP7__State__c != "") SA += saddr.ERP7__State__c+', ';
                                if(saddr.ERP7__Postal_Code__c != undefined && saddr.ERP7__Postal_Code__c != "") SA += saddr.ERP7__Postal_Code__c+', ';
                                if(saddr.ERP7__Country__c != undefined && saddr.ERP7__Country__c != "") SA += saddr.ERP7__Country__c;
                                cmp.set("v.pageSubscription.ERP7__Ship_To_Address__c",SA);
                                //alert('sa : '+SA);
                            }
                        } 
                    }
                    try{ 
                        cmp.set("v.NewAddressError", "");
                        cmp.set("v.NewAddress.ERP7__Address_Line1__c", ""); 
                        cmp.set("v.NewAddress.ERP7__Address_Line2__c", ""); 
                        cmp.set("v.NewAddress.ERP7__Address_Line3__c", ""); 
                        cmp.set("v.NewAddress.ERP7__City__c", ""); 
                        cmp.set("v.NewAddress.ERP7__Postal_Code__c", ""); 
                        cmp.set("v.NewAddress.ERP7__Primary__c", false);
                        cmp.set("v.NewAddress.ERP7__Is_Billing_Address__c", false);
                        cmp.set("v.NewAddress.ERP7__Is_Shipping_Address__c", false);
                    } catch(err){}
                    
                }else if (response.getState() === "ERROR") {
                    var errors = response.getError();
                    var errlist = [];
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                cmp.set("v.NewAddressError", errors[0].message);
                    
                            } else if (errors[0] && errors[0].pageErrors) {
                                cmp.set("v.NewAddressError", errors[0].pageErrors[0].message);
                    
                            } else if(errors[0] && errors[0].fieldErrors) {
                                    var obj = errors[0].fieldErrors;
                                    for(var fieldname in obj)
                                    console.log('err Message '+obj[fieldname][0].message);
                                    errlist.push(obj[fieldname][0].message);  
                                }
                                cmp.set("v.NewAddressError",errlist.toString()); 
                        }
                }
            });
            $A.enqueueAction(action);
            $A.util.removeClass(cmp.find("myModalAdr"),"slds-fade-in-open");
            $A.util.removeClass(cmp.find("myModalAdrBackdrop"),"slds-backdrop_open");
        }
        
    },
    
     lookupChangeOrder : function(cmp) {
        
        if(cmp.get("v.proceed")){
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            cmp.set("v.proceed",false);
            var ord = cmp.get("v.SalesOrder.Id");
            //alert('ord  '+ord);
            if(ord != null && ord != '' && ord != undefined){ //&& cmp.get("v.SBool")
                cmp.set("v.SBool",false);
                var qry;
                if(ord == undefined) qry = ' ';
                else qry = 'And ERP7__Order__c = \''+ord+'\''+' AND ERP7__Total_Due__c > 0.0';
                cmp.set("v.qry2",qry);
                //cmp.set("v.Customer", null);
                //cmp.set("v.Contact", null);
                cmp.set("v.SON",ord);
                cmp.set("v.CON","");
                cmp.set("v.CUST","");
                cmp.popInit();
            } else{
                //alert('SO CON');
                var currentTime = new Date();
                cmp.set("v.SalesOrder.ERP7__Expected_Date__c","");
                cmp.set("v.SalesOrder.ERP7__Payments_Status__c","");
                var con = cmp.get("v.Contact.Id");
                cmp.set("v.SON","");
                cmp.set("v.CON",con);
                cmp.set("v.CUST","");
                cmp.popInit();
            }
        }
    },
    
    lookupChangeAccount : function(cmp) {
        //alert('lookupChangeAccount');
        if(cmp.get("v.proceed")){
            cmp.set("v.proceed",false);
            var acc = cmp.get("v.Customer.Id");
            //alert(acc);

            if(acc != null && acc != '' && acc != undefined && cmp.get("v.ABool")){
                cmp.set("v.ABool",false);
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                cmp.set("v.Customer", null);
                cmp.set("v.Contact", null);
                //cmp.set("v.SalesOrder", null);
                cmp.set("v.SON","");
                cmp.set("v.CON","");
                cmp.set("v.CUST",acc);
                cmp.set("v.proceed",false);
                cmp.popInit();
                
            } else {
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                try{ $A.get('e.force:refreshView').fire(); } catch(err){
            		window.location.href = '/apex/ERP7__POSLC';
                }
            }
        }
    },
    lookupChangeContact : function(cmp) {
        //alert('lookupChangeContact');
        if(cmp.get("v.proceed")){
            cmp.set("v.proceed",false);
            
            var con = cmp.get("v.Contact.Id");
            //alert(con);
            if(con != null && con != '' && con != undefined && cmp.get("v.CBool")){
                cmp.set("v.CBool",false);
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                cmp.set("v.Customer", null);
                cmp.set("v.Contact", null);
                
                cmp.set("v.SON","");
                cmp.set("v.CON",con);
                cmp.set("v.CUST","");
                cmp.popInit();
            } else {
                /*var acc = cmp.get("v.Customer.Id");
            	//alert('con acc '+acc);
                if(acc != null && acc != '' && acc != undefined){
                    cmp.set("v.Customer", null);
                    cmp.set("v.Contact", null);
                    //cmp.set("v.SalesOrder", null);
                    cmp.set("v.SON","");
                    cmp.set("v.CON","");
                    cmp.set("v.CUST",acc);
                    cmp.popInit();
                    
                }*/
            }
            
        }
    },
    
    Navigat : function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var target = event.getSource();
        var RecId = event.getSource().get("v.title");
        var ObjType = target.get("v.class");
        //alert(ObjType);
        //alert(RecId);
        if(ObjType == "Account"){
            cmp.set("v.SON","");
            cmp.set("v.CON","");
            cmp.set("v.CUST",RecId);
        } else if(ObjType == "Contact"){
            cmp.set("v.SON","");
            cmp.set("v.CON",RecId);
            cmp.set("v.CUST","");
        }else if(ObjType == "ERP7__Sales_Order__c"){
            cmp.set("v.SON",RecId);
            cmp.set("v.CON","");
            cmp.set("v.CUST","");
        }
        cmp.set("v.proceed",false);
        cmp.popInit();
        
    },
    
    
    ABool:function(cmp,helper){
        cmp.set("v.ABool",true);        
    },
    CBool:function(cmp,helper){
        cmp.set("v.CBool",true);        
    },
    SBool:function(cmp,helper){
        cmp.set("v.SBool",true);        
    },
    
    lookupClickAccount:function(cmp,helper){
        cmp.set("v.qry","");        
    },
    lookupClickContact:function(cmp,helper){
        
        var acc = cmp.get("v.Customer.Id");
        //alert(acc);
        var qry;
        if(acc == undefined) qry = ' ';
        else qry = 'And AccountId = \''+acc+'\'';
        cmp.set("v.qry",qry);
        
    },
    lookupClickOrder:function(cmp,helper){
        var acc = cmp.get("v.Customer.Id");
        //alert(acc);
        var qry;
        if(acc == undefined) qry = ' ';
        else qry = 'And Account__c = \''+acc+'\'';
        cmp.set("v.qry",qry);
        
    },
    lookupClickBlank:function(cmp,helper){
        cmp.set("v.qry",""); 
    },
    lookupClickAddressContact:function(cmp,helper){
        var acc = cmp.get("v.NewCust.Id");
        //alert(acc);
        var qry;
        if(acc == undefined) qry = ' ';
        else qry = ' And AccountId = \''+acc+'\'';
        cmp.set("v.qry",qry);
        /*
        var evt = $A.get("e.c:SetQRYParam");
        evt.setParams({
            qry: cmp.get("v.qry")
        });
        evt.fire(); 
        */
    },
    lookupClickProfile:function(cmp,helper){
        var acc = "Customer";
        var qry = ' And ERP7__Record_Type_Name__c = \''+acc+'\'';
        cmp.set("v.qry",qry);
        
    },
    
    
    doneRendering : function(cmp) {
        //alert('doneRendering'); 
        cmp.set("v.proceed",true);
    },
    
    
    getAllDetails : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        
        //var showPersonAcc = $A.get("$Label.c.EPOS_Show_Person_Account");
        //component.set("v.showPersonAcc",showPersonAcc);
        var controllingFieldAPI = cmp.get("v.controllingFieldAPI");
        var dependingFieldAPI = cmp.get("v.dependingFieldAPI");
        var objDetails = cmp.get("v.objDetail");
        // call the helper function
        helper.fetchPicklistValues(cmp,objDetails,controllingFieldAPI, dependingFieldAPI);
        var vson = cmp.get("v.SON");
        var vcon = cmp.get("v.CON");
        var vcust = cmp.get("v.CUST");
        var action = cmp.get("c.getAll");
        action.setParams({sony:vson,cony:vcon,custy:vcust,accf:",ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ",conf:""});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try { 
                    
                    cmp.find("STP").set("v.options", response.getReturnValue().shipmentType);
                    cmp.set("v.SalesOrder", response.getReturnValue().Order);
                    
                    cmp.set("v.com.ERP7__Sales_Order__c", response.getReturnValue().Order.Id);
                    cmp.set("v.Customer", response.getReturnValue().Customer);
                    cmp.set("v.Contact", response.getReturnValue().Contact);
                    cmp.set("v.customerCreditLimit", response.getReturnValue().Customer.ERP7__total_points__c);
                    
                    //alert(response.getReturnValue().BillAddresses.ERP7__City__c);
                    cmp.set("v.Custo.ERP7__Profiling__c", response.getReturnValue().Customer.ERP7__Profiling__c);
                    cmp.set("v.Custo.ERP7__VAT__c", response.getReturnValue().Customer.ERP7__VAT__c);
                    //cmp.set("v.custInvoiceTest.ERP7__Account__c", response.getReturnValue().Customer.Id);
                    //cmp.set("v.custInvoiceTest.ERP7__Account__r.Name", response.getReturnValue().Customer.Name);
                    cmp.set("v.NewContact.AccountId", response.getReturnValue().Customer.Id);
                    cmp.set("v.NewCust", response.getReturnValue().Customer);
                    cmp.set("v.NewAddress.ERP7__Customer__c", response.getReturnValue().Customer.Id);
                    cmp.set("v.addAddress.ERP7__Contact__c", response.getReturnValue().Contact.Id);
                    cmp.set("v.NewAddress.ERP7__Contact__c", response.getReturnValue().Contact.Id);
                    cmp.set("v.NewCon", response.getReturnValue().Contact);
                    cmp.set("v.currentSalepoint", response.getReturnValue().currentSalepoint);
                    cmp.set("v.currentEmployee", response.getReturnValue().currentEmployee);
                    var emp = cmp.get("v.currentEmployee");
                    if(response.getReturnValue().Order.Id != undefined && response.getReturnValue().Order.ERP7__Employees__c != undefined) {
                        emp.Id = response.getReturnValue().Order.ERP7__Employees__c;
                        emp.Name = response.getReturnValue().Order.ERP7__Employees__r.Name;
                        cmp.set("v.currentEmployee", emp);
                    }
                    cmp.set("v.SalesOrder.ERP7__Employees__c", response.getReturnValue().Order.ERP7__Employees__c);
                    
                    //cmp.set("v.Invoice", response.getReturnValue().invoice);
                    //cmp.set("v.Invoiced",response.getReturnValue().invoice);
                    if(response.getReturnValue().isMultiCurrency){
                        cmp.set("v.isMultiCurrency",response.getReturnValue().isMultiCurrency);
                        cmp.set("v.orderCurrency",response.getReturnValue().orderCurrency);
                    }
                    //alert(response.getReturnValue().invoice.Id);
                    if(response.getReturnValue().Order.ERP7__Organisation__c != undefined) {
                    cmp.set("v.orgId",response.getReturnValue().Order.ERP7__Organisation__c);
                    //alert(cmp.get("v.orgId"));
                    }
                    cmp.set("v.invoiceName", '');
                    /*if(response.getReturnValue().invoice.Name == null) {  } 
                    else cmp.set("v.invoiceName", response.getReturnValue().invoice.Name);*/
                    cmp.set("v.pageSubscription", response.getReturnValue().pageSubscription);
                    cmp.set("v.itemWrapperListt", response.getReturnValue().itemWrapperListCom);
                    cmp.set("v.subTotal", response.getReturnValue().subTotal);
                    cmp.set("v.discounts", response.getReturnValue().totalDiscount);
                    cmp.set("v.taxes", response.getReturnValue().totalTax);
                    cmp.set("v.totalDue", response.getReturnValue().totalDue);
                    //cmp.set("v.amountPaid", response.getReturnValue().itemWrapperListCom);
                    cmp.set("v.loyaltyPoints", response.getReturnValue().loyalty_Points);
                    cmp.set("v.loyaltyAmount", response.getReturnValue().loyaltyAmount);
                    cmp.set("v.Payments", response.getReturnValue().SO_Payments);
                    cmp.set("v.CreditNotes", response.getReturnValue().creditNotes);
                    cmp.set("v.Shipments", response.getReturnValue().Shipments);
                    cmp.set("v.Payment", response.getReturnValue().Payment);
                    cmp.set("v.PaymentMethod", response.getReturnValue().PaymentMethod);
                    cmp.set("v.Payment.ERP7__Total_Amount__c", '');
                    cmp.set("v.Payment.ERP7__Bank__c", '');
                    cmp.set("v.Payment.ERP7__Reference_Cheque_No__c", '');
                    cmp.set("v.fieldError", '');
                    cmp.set("v.Payment.ERP7__Bank_Code__c",'');
                    cmp.set("v.Payment.ERP7__Account_Holder_Name__c", '');
                    cmp.set("v.Payment.ERP7__Account_Number__c", '');
                    cmp.set("v.Payment.ERP7__Account_Type__c", '');
                    cmp.set("v.PaymentMethod.ERP7__Name_on_Card__c", '');
                    cmp.set("v.PaymentMethod.ERP7__CardType__c", '');
                    cmp.set("v.PaymentMethod.ERP7__Card_Number__c", '');
                    cmp.set("v.CVV", '');
                    cmp.set("v.PaymentMethod.ERP7__Card_Expiration_Month__c", '');
                    cmp.set("v.PaymentMethod.ERP7__Card_Expiration_Year__c", '');
                    cmp.set("v.CardError", '');
                    cmp.set("v.BankError", '');
                    cmp.set("v.CashError", '');
                    cmp.set("v.finalDue", response.getReturnValue().finalDue);
                    cmp.find("InputSelectDynamic").set("v.options", response.getReturnValue().SOPS);
                    if(response.getReturnValue().Order.ERP7__Order_Profile__c != undefined) cmp.set("v.SOP",response.getReturnValue().Order.ERP7__Order_Profile__c);
                    //alert(response.getReturnValue().Customer.ERP7__Account_Profile__c);
                    var accp1 = new Object();
                    var tax1 = new Object();
                    if(response.getReturnValue().Customer.ERP7__Account_Profile__c != undefined) {
                        accp1.Id = response.getReturnValue().Customer.ERP7__Account_Profile__c;
                        accp1.Name = response.getReturnValue().Customer.ERP7__Account_Profile__r.Name;
                    }
                    var pr = cmp.get("v.proceed");
                    //alert('pr : '+pr);
                    if(response.getReturnValue().Customer.ERP7__VAT__c != undefined) {
                        tax1.Id = response.getReturnValue().Customer.ERP7__VAT__c;
                        tax1.Name = response.getReturnValue().Customer.ERP7__VAT__r.Name;
                    }
                    cmp.set("v.AccProfile1",accp1);
                    cmp.set("v.AccTax1",tax1);
                    cmp.find("cardType").set("v.options", response.getReturnValue().CardTypes);
                    cmp.find("expiryMonth").set("v.options", response.getReturnValue().ExpiryMonth);
                    cmp.find("expiryYear").set("v.options", response.getReturnValue().ExpiryYear);
                    cmp.find("bAdding4").set("v.options", response.getReturnValue().CountryList);
                    cmp.find("bAdding6").set("v.options", response.getReturnValue().CountyList);
                    //cmp.find("bAdding5").set("v.options", response.getReturnValue().ConList);
                    cmp.find("cardType").set("v.options", response.getReturnValue().CardTypes);
                    cmp.find("bAdd").set("v.options", response.getReturnValue().bAdd); 
                    cmp.find("sAdd").set("v.options", response.getReturnValue().sAdd);
                    cmp.find("orderStatus").set("v.options", response.getReturnValue().orderStatus);
                    
                    //cmp.find("CountryList").set("v.options", response.getReturnValue().CountryList);
                    //cmp.find("CountyList").set("v.options", response.getReturnValue().CountyList);
                    cmp.find("prodFam").set("v.options", response.getReturnValue().prodFam);
                    cmp.find("prodCat").set("v.options", response.getReturnValue().prodCat);
                    cmp.find("prodSubCat").set("v.options", response.getReturnValue().prodSubCat);
                    //alert(response.getReturnValue().shipmentType); ERP7__Shipment_Type__c
                    //cmp.find("STP").set("v.options", response.getReturnValue().shipmentType);
                    cmp.set("v.orderStatus", response.getReturnValue().Order.ERP7__Status__c); 
                  
         
                    cmp.set("v.bAdd",response.getReturnValue().Order.ERP7__Bill_To_Address__c);
                    cmp.set("v.sAdd",response.getReturnValue().Order.ERP7__Ship_To_Address__c);
                    cmp.set("v.RecentlyViewedList", response.getReturnValue().recentRecords);           
                    cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                    var ProductsAndDiscountsWrapListt = new Array();
                    cmp.set("v.Points_Per_Unit_Amount", response.getReturnValue().Points_Per_Unit_Amount);
                    cmp.set("v.ProductsAndDiscountsWrapperListt", ProductsAndDiscountsWrapListt);
                    //cmp.set("v.proceed",true);
                    cmp.set("v.TaxRate",response.getReturnValue().TaxRate);
                    cmp.set("v.accTaxRate",response.getReturnValue().accTaxRate);
                    cmp.set("v.pdLists",[]);
                    if(cmp.get("v.SalesOrder.ERP7__Authorised__c") == true && cmp.get("v.SalesOrder.Id") != null && cmp.get("v.SalesOrder.Id") != undefined && cmp.get("v.SalesOrder.Id") != ''){
                        cmp.set("v.isSO_Authorised", true);
                    }
                    else{
                        cmp.set("v.isSO_Authorised", false);
                    }
                    //alert(cmp.get("v.isSO_Authorised"));
                    //helper.eposFieldAccess(cmp, event);
                    cmp.set("v.BillAddress", response.getReturnValue().BillAddresses);
                    var action = cmp.get("c.eposCheckFLS");
                    action.setCallback(this,function(response){
                        if(response.getState() === "SUCCESS"){
                            cmp.set('v.eposFLSCheck',response.getReturnValue());
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            
                        }
                        else{
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            var errors = response.getError();
                            console.log("err -> ", errors);
                        }
                    });
                    $A.enqueueAction(action);
                } catch(err) {
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                }
            }else{
                console.log('Error:',response.getError());
            }
        });
        
        $A.enqueueAction(action);
        
        helper.fetchPaymentType(cmp, event, helper);
        helper.fetchCRUD(cmp, event, helper);
    },
    
    //Controlling dependent picklist in Address
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
    
    getAllDetailsInit : function(cmp) {
        //var Reset = '/one/one.app?source=aloha#/n/ERP7__ePoS';
        //window.location.href = '/apex/ERP7__POSLC';
        //window.open(Reset,'_self');
        try{ $A.get('e.force:refreshView').fire(); }catch(err){
            window.location.href = '/apex/ERP7__POSLC';
        }
        //$A.enqueueAction(action);
    },
    
    ApplyCoupon : function(cmp) {
        var SO = cmp.get("v.SalesOrder");
        var SalesOrder2Creates = JSON.stringify(SO);
        var Coupon = cmp.get("v.Coupon");
        var Customers = new Array(cmp.get("v.Customer"));
        var Contacts = new Array(cmp.get("v.Contact"));
        if(SO.Id != undefined && Coupon != undefined && Coupon != ''){
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.ApplyCoupons");
            action.setParams({
                SalesOrder2Creates: SalesOrder2Creates, 
                Customers1: JSON.stringify(Customers),
                Contacts1: JSON.stringify(Contacts),
                Coupon: Coupon
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();                
                if (cmp.isValid() && state === "SUCCESS") {
                    //alert(state);
                    
                    if(response.getReturnValue().Error == true){
                        //alert(response.getReturnValue().Error);
                        cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                    }
                    else{
                        cmp.set("v.exceptionError",'');
                        var sonId = response.getReturnValue().Value;
                        cmp.set("v.SON",sonId);
                        cmp.popInit();
                    }
                } else if (response.getState() === "ERROR") {
                    var errors = response.getError();
                    if(errors[0] && errors[0].pageErrors) {
                      
                        cmp.set("v.exceptionError",errors[0].pageErrors[0].message);
                    }
                }
                 $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                
            });
            $A.enqueueAction(action);
        }  
    },
    
    render : function(cmp) {
        var element = this.superRender();
        element[0].children[0].removeAttribute('disabled');
        return element;
    },
    
    getOrder : function(cmp) {
        var action = cmp.get("c.getSalesOrder");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.SalesOrder", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    getCust : function(cmp) {
        var action = cmp.get("c.getCustomer");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.Customer", response.getReturnValue());
                //if(response.getReturnValue().Id != '') 
            }
        });
        $A.enqueueAction(action);
    },
    
    getCon : function(cmp) {
        var action = cmp.get("c.getContact");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.Contact", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    onSelectBA : function(cmp) {
        var baId = cmp.find("bAdd").get("v.value");
        var Taxaction = cmp.get("c.getTaxRateByAddressId");
        Taxaction.setParams({AddId:baId});
        Taxaction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(cmp.get("v.TaxRate")>0.00 && parseFloat(response.getReturnValue()) > 0.00){
                    cmp.set("v.TaxRate", response.getReturnValue());
                    var UpdateTaxaction = cmp.get("c.updateTax_OnAddressChange");
                    UpdateTaxaction.setParams({selWrap:JSON.stringify(cmp.get("v.itemWrapperListt")),TaxRate:cmp.get("v.TaxRate")});
                    UpdateTaxaction.setCallback(this,function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            cmp.set("v.itemWrapperListt", response.getReturnValue());
                        }
                    });
                    $A.enqueueAction(UpdateTaxaction);
                }
            }
        });
        
        var action = cmp.get("c.getBA");
        action.setParams({baId:cmp.find("bAdd").get("v.value")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.pageSubscription.ERP7__Bill_To_Address__c", response.getReturnValue());
                $A.enqueueAction(Taxaction);
            }
        });
        $A.enqueueAction(action);
    },
    
    onSelectSA : function(cmp) {
        var saId = cmp.find("sAdd").get("v.value");
        var Taxaction = cmp.get("c.getTaxRateByAddressId");
        Taxaction.setParams({AddId:saId});
        Taxaction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(parseFloat(response.getReturnValue()) >= 0.000){
                    cmp.set("v.TaxRate", response.getReturnValue());
                }else{
                     cmp.set("v.TaxRate", cmp.get("v.accTaxRate"));
                }
                if(cmp.get("v.TaxRate")>=0.000){
                    var UpdateTaxaction = cmp.get("c.updateTax_OnAddressChange");
                    UpdateTaxaction.setParams({selWrap:JSON.stringify(cmp.get("v.itemWrapperListt")),TaxRate:cmp.get("v.TaxRate")});
                    UpdateTaxaction.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            cmp.set("v.itemWrapperListt", response.getReturnValue());
                        }
                    });
                    $A.enqueueAction(UpdateTaxaction);
                }
            }
        });
        
        var action = cmp.get("c.getSA");
        action.setParams({saId:saId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.pageSubscription.ERP7__Ship_To_Address__c", response.getReturnValue());
                $A.enqueueAction(Taxaction);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchProduct : function(cmp, event, helper) {
        try{
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
            var SalesOrder2Creates = new Array(cmp.get("v.SalesOrder"));
            var isBackOrders = SalesOrder2Creates[0].ERP7__Is_Back_Order__c;
            var isPreOrders = SalesOrder2Creates[0].ERP7__Is_Pre_Order__c;
            if(isBackOrders != true) isBackOrders = false;
            if(isPreOrders != true) isPreOrders = false;
            var Customers = new Array(cmp.get("v.Customer"));
            var Contacts = new Array(cmp.get("v.Contact"));
            var i = cmp.get("v.itemName");
            var j = cmp.get("v.prodFam");
            var k = cmp.get("v.SOP");
            var l = cmp.get("v.itemWrapperListt");
            cmp.set("v.productLimit",200);
            var productLimit = cmp.get("v.productLimit");
            var IsRental = cmp.get("v.IsRental");
            var ExpectedDate = SalesOrder2Creates[0].ERP7__Expected_Date__c;
            var action = cmp.get("c.productFetchss");
            action.setParams({
                itemName: cmp.get("v.itemName"),
                ProdFam: cmp.get("v.prodFam"),
                ProdCat: cmp.get("v.prodCat"),
                ProdSubCat: cmp.get("v.prodSubCat"),
                currentSalepoints1: JSON.stringify(currentSalepoints),
                Customers1: JSON.stringify(Customers),
                Contacts1: JSON.stringify(Contacts),
                SOP: cmp.get("v.SOP"),
                itemWrapperList: JSON.stringify(cmp.get("v.itemWrapperListt")),
                isBackOrder: isBackOrders,
                isPreOrder: isPreOrders,
                ExpectedDate: ExpectedDate,
                productLimit: productLimit
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var obj = response.getReturnValue();
                    var objEdit = new Array();
                    for(var x in obj){
                        var pro = obj[x];
                        obj[x].product_Type = 'N/A';
                        if(Boolean(pro.trackInventory) || Boolean(pro.product.ERP7__Is_Asset__c)){
                            /*Inventory Product*/
                            if(Boolean(pro.product.ERP7__Is_Asset__c)){
                                /*Rental Product*/
                                
                                if(pro.stock !='' && pro.stock != undefined && parseFloat(pro.stock) > 0){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = pro.stock;
                                }else{
                                    obj[x].product_Type = (pro.stock === undefined)?0:pro.stock;
                                }
                                
                            }else{
                                /*Non Rental Product*/
                                if(pro.stock !='' && pro.stock != undefined && pro.stock > 0){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = pro.stock;
                                }   
                                else if(Boolean(pro.product.ERP7__Allow_Back_Orders__c)){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = 'Back-Order';
                                }
                                else if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = 'Pre-Order';
                                }
                                else{
                                    obj[x].product_Type = (pro.stock === undefined)?0:pro.stock;
                                }
                            }  
                        }else{
                            /*Non Inventory Product*/
                            if(Boolean(pro.product.ERP7__Is_Kit__c)){
                                /*Kit Product*/
                                obj[x].showcbox = true;
                                obj[x].product_Type = 'Kit';
                                if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                    obj[x].product_Type = 'Kit (Pre-Order)';
                                }
                                else if(Boolean(pro.product.ERP7__Allow_Back_Orders__c)){
                                    obj[x].product_Type = 'Kit (Back-Order)';
                                } 
                            }
                            /*Non Kit Product*/   
                            else if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                obj[x].product_Type = 'Pre-Order';
                                obj[x].showcbox = true;
                            }
                            else if(pro.product.ERP7__Status__c === 'Released'){
                                    obj[x].product_Type = pro.product.ERP7__Item_Type__c;
                                    obj[x].showcbox = true;
                             }    
                        }
                       
                        objEdit.push(obj[x]);
                    }
                    cmp.set("v.ProductsAndDiscountsWrapperListt", objEdit);
                    var objEditN = cmp.get("v.ProductsAndDiscountsWrapperListt");
                    cmp.set("v.ProductsAndDiscountsWrapperListt", objEditN);
                    cmp.set("v.pdLists", new Array());
                    if(cmp.get("v.SerialPopup")) {
                        cmp.set("v.SerialPopup",false);
                    }
                }
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            });
            $A.enqueueAction(action);
        } catch(err) {
            console.log('fetchProduct ==> Exception Occured '+err);
        }
    },
    
    getSerials : function(cmp, event) {
        //var delayInMilliseconds = 1000; //1 second
        //setTimeout(function() {
            //your code to be executed after 1 second
            try{
                var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
                var Customers = new Array(cmp.get("v.Customer"));
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                var count = event.getSource().get("v.name"); 
                //alert(count);
                //var count = cmp.get("v.CountHolder");      
                if(count === '') {
                    //alert('In If');
                    count = cmp.get("v.CountHolder");
                    cmp.set("v.CountHolder", count);
                }
                //alert(count);
                var SerialNumber = cmp.get("v.SerialNumber");
                if(SerialNumber == undefined) SerialNumber = "";
                var obj = cmp.get("v.ProductsAndDiscountsWrapperListt");
                var objsel = [];
                for(var x in obj){
                    if(x == count) {
                        //alert(x);
                        objsel.push(obj[count]);
                        cmp.set("v.SelectedProduct", objsel[0]);
                        cmp.set("v.CountHolder", count);
                        break;
                    }
                }
                
                var objItem = cmp.get("v.itemWrapperListt");
                for(var x in objItem){
                    if(objItem[x].product.Id == objsel[0].product.Id){
                        for(var z in objItem[x].SerialNos){
                            //objsel[0].SerialNos.push(objItem[x].SerialNos[z]);
                        }
                    }
                }
                var action = cmp.get("c.getSerialNos");
                action.setParams({
                    currentSalepoints1: JSON.stringify(currentSalepoints),
                    Customers1: JSON.stringify(Customers),
                    objsel: JSON.stringify(objsel[0]),
                    SerialNumber: SerialNumber
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        var res = response.getReturnValue();
                        //alert(objsel[0].product.Id);
                        for(var x in res){
                            res[x].product = objsel[0].product;
                            res[x].pricebookEntry = objsel[0].pricebookEntry;
                        }
                        cmp.set("v.pdLists", res);
                        cmp.set("v.IsRental", objsel[0].product.ERP7__Is_Asset__c);
                        cmp.set("v.SerialPopup", true);
                        cmp.set("v.BatchPopup", false);
                    }
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            } catch(err) {
                console.log("Exception : "+err.message);
            }
        //}, delayInMilliseconds);
        
    },
    
    getBatches : function(cmp, event) {
        //var delayInMilliseconds = 1000; //1 second
        //setTimeout(function() {
            //your code to be executed after 1 second
            try{
                var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
                var Customers = new Array(cmp.get("v.Customer"));
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                var count = event.getSource().get("v.name"); 
                //alert('In getBatches : '+count);
                //var count = cmp.get("v.CountHolder");      
                if(count === '') {
                    //alert('In If');
                    count = cmp.get("v.CountHolder");
                    cmp.set("v.CountHolder", count);
                }
                //alert('In getBatches : '+count);
                var BatchNumber = cmp.get("v.BatchNumber");
                if(BatchNumber == undefined) BatchNumber = "";
                var obj = cmp.get("v.ProductsAndDiscountsWrapperListt");
                var objsel = [];
                for(var x in obj){
                    if(x == count) {
                        //alert(x);
                        objsel.push(obj[count]);
                        cmp.set("v.SelectedProduct", objsel[0]);
                        cmp.set("v.CountHolder", count);
                        break;
                    }
                }
                
                var objItem = cmp.get("v.itemWrapperListt");
                for(var x in objItem){
                    if(objItem[x].product.Id == objsel[0].product.Id){
                        for(var z in objItem[x].SerialNos){
                            //objsel[0].SerialNos.push(objItem[x].SerialNos[z]);
                        }
                    }
                }
                var action = cmp.get("c.getBatchNos");
                action.setParams({
                    currentSalepoints1: JSON.stringify(currentSalepoints),
                    Customers1: JSON.stringify(Customers),
                    objsel: JSON.stringify(objsel[0]),
                    BatchNumber: BatchNumber
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        var res = response.getReturnValue();
                        //alert(objsel[0].product.Id);
                        for(var x in res){
                            res[x].product = objsel[0].product;
                            res[x].pricebookEntry = objsel[0].pricebookEntry;
                        }
                        cmp.set("v.pdLists", res);
                        cmp.set("v.SerialPopup", false);
                        cmp.set("v.BatchPopup", true);
                    }
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            } catch(err) {
                alert("Exception : "+err.message);
            }
        //}, delayInMilliseconds);
        
    },
    
    getBatchesEdit : function(cmp, event) {
        try{
            var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
            var Customers = new Array(cmp.get("v.Customer"));
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var BatchNumber = cmp.get("v.BatchNumber");
            if(BatchNumber == undefined) BatchNumber = "";
            var obj = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
            var objsel = [];
            for(var x in obj){
                objsel.push(obj[x]);
                cmp.set("v.SelectedProduct", objsel[x]);
                cmp.set("v.CountHolder", x);
            }
            
            var action = cmp.get("c.getBatchNos");
            action.setParams({
                currentSalepoints1: JSON.stringify(currentSalepoints),
                    Customers1: JSON.stringify(Customers),
                objsel: JSON.stringify(objsel[0]),
                BatchNumber: BatchNumber
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    var res = response.getReturnValue();
                    //alert(objsel[0].product.Id);
                    for(var x in res){
                        res[x].product = objsel[0].product;
                        res[x].pricebookEntry = objsel[0].pricebookEntry;
                    }
                    cmp.set("v.pdLists", res);
                    cmp.set("v.SerialPopup", false);
                    cmp.set("v.BatchPopup", true);
                }
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            });
            $A.enqueueAction(action);
        } catch(err) {
            alert("Exception : "+err.message);
        }
    },
    
    getAvailableSerials : function(cmp, event) {
        //try{
            var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
            var Customers = new Array(cmp.get("v.Customer"));
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var count = 0;
            var SerialNumber = cmp.get("v.SerialNumber");
            if(SerialNumber == undefined) SerialNumber = "";
            var obj = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
            var objsel = [];
            for(var x in obj){
                if(x == count) { 
                    objsel.push(obj[count]);
                    break;
                }
            }
            var objItem = cmp.get("v.itemWrapperListt");
            for(var x in objItem){
                if(objItem[x].product.Id == objsel[0].product.Id){
                    for(var z in objItem[x].SerialNos){
                        //objsel[0].SerialNos.push(objItem[x].SerialNos[z]);
                    }
                }
            }
            var action = cmp.get("c.getSerialNos");
            action.setParams({
                currentSalepoints1: JSON.stringify(currentSalepoints),
                Customers1: JSON.stringify(Customers),
                objsel: JSON.stringify(objsel[0]),
                SerialNumber: SerialNumber
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    var res = response.getReturnValue();
                    for(var x in res){
                        res[x].product = objsel[0].product;
                        res[x].pricebookEntry = objsel[0].pricebookEntry;
                    }
                    cmp.set("v.pdLists", res);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        //} catch(err) {
            //alert("Exception : "+err.message);
        //}
    },
    
    assignEndDateEdit: function (cmp, event) {
        
        var count = event.getSource().get("v.labelClass");
        var obj = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
        if(obj[0].SerialNos[count].ERP7__Start_Date__c != undefined && obj[0].SerialNos[count].ERP7__Start_Date__c != '' && obj[0].SerialNos[count].ERP7__End_Date__c != undefined && obj[0].SerialNos[count].ERP7__End_Date__c != ''){
            var st = new Date(obj[0].SerialNos[count].ERP7__Start_Date__c);
            var en = new Date(obj[0].SerialNos[count].ERP7__End_Date__c);
            if(en.getTime() < st.getTime()){
                obj[0].SerialNos[count].ERP7__End_Date__c = obj[0].ERP7__Start_Date__c;
            }
            cmp.set("v.ProductsAndDiscountsWrapperListtEdit",obj);
        }
    },
    
    removeSerial: function(cmp, event) {
        //var r = confirm("Are you sure you want to delete?");
        //if(r == true) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var count = event.getSource().get("v.name");
            var obj = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
            var Serials2Delete = cmp.get("v.Serials2Delete");
            Serials2Delete.push(obj[0].SerialNos[count].Id);
            var SalesOrder2Creates = JSON.stringify(cmp.get("v.SalesOrder"));
            
            var action = cmp.get("c.deleteSerials");
            action.setParams({
                Serials2Delete: cmp.get("v.Serials2Delete"),
                SalesOrder2Creates: SalesOrder2Creates
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    cmp.set("v.Serials2Delete",[]);
                    var res = new Object();
                    res.Serial = obj[0].SerialNos[count];
                    if(res.Serial.ERP7__Asset__c != undefined && res.Serial.ERP7__Asset__c != null){
                        res.Serial.ERP7__Asset__r.ERP7__Available__c = true;
                        res.Serial.ERP7__Asset__r.ERP7__Status__c = 'Available';
                        if(res.Serial.ERP7__Start_Date__c != undefined && res.Serial.ERP7__Start_Date__c != '' && res.Serial.ERP7__End_Date__c != undefined && res.Serial.ERP7__End_Date__c != ''){
                            //var s = '01-01-1970 00:03:44';
                            //var e = '01-01-1970 00:03:44';
                            res.StartTime = res.Serial.ERP7__Start_Date__c;
                            res.EndTime = res.Serial.ERP7__End_Date__c;
                        }
                    }
                    var pnds = cmp.get("v.pdLists");
                    pnds.push(res);
                    cmp.set("v.pdLists", pnds);
                
                    obj[0].SerialNos.splice(count, 1);
                    cmp.set("v.ProductsAndDiscountsWrapperListtEdit",obj);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        //}
    },
    
    getFromSerials : function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var obj = cmp.get("v.pdLists");
        var SerialNumber = cmp.get("v.SerialNumber");
        var objselList = [];
        for(var x in obj){
            var str = obj[x].Serial.ERP7__Serial_Number__c;
            if(SerialNumber != undefined && str != undefined && str.indexOf(SerialNumber) != -1){ 
                var objsel = obj[x];
                objselList.push(obj[x]);
            }
        }
        cmp.set("v.pdLists", objselList);
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
    },
    
    back2Items: function(cmp, event) {
        cmp.set("v.SerialPopup", false);
        cmp.set("v.BatchPopup", false);
    },
    
    addDiscount : function(cmp, event) {
        //try{
            //alert('IN');
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var count = event.getSource().get("v.labelClass");
            var CountHolder = cmp.get("v.CountHolder");
            var obj = cmp.get("v.ProductsAndDiscountsWrapperListt");
            var objsel;
            for(var x in obj){
                if(x == count) { 
                    objsel = obj[count];
                    if(CountHolder == count) cmp.set("v.SelectedProduct", objsel);
                }
            }
            if(objsel.product.ERP7__Serialise__c && !objsel.product.ERP7__Is_Asset__c && objsel.SerialNos.length > objsel.quantity_s){
                objsel.quantity_s = objsel.SerialNos.length;
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
            else{
                var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
                var SalesOrder2Creates = cmp.get("v.SalesOrder");
                var Customers = new Array(cmp.get("v.Customer"));
                var Contacts = new Array(cmp.get("v.Contact"));
                var SOP = cmp.get("v.SOP");
                var isBackorder = (SalesOrder2Creates.ERP7__Is_Back_Order__c == true)? true : false;
                if(objsel.quantity_s == "") objsel.quantity_s = 0;
                
                var action = cmp.get("c.DiscountPlans");
                action.setParams({
                    itemId: objsel.product.Id,
                    currentSalepoints1: JSON.stringify(currentSalepoints),
                    isBackorder: isBackorder, 
                    Customers1: JSON.stringify(Customers),
                    Contacts1: JSON.stringify(Contacts),
                    SOP: SOP,
                    quantity_s: objsel.quantity_s,
                    Version: objsel.Version
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        cmp.set("v.ProductsAndDiscountsWrapperListt", '');
                        for(var x in obj){
                            if(x == count) { 
                                //obj[count] = response.getReturnValue();
                                obj[count].quantity_s = response.getReturnValue().quantity_s;
                                obj[count].isPercent = response.getReturnValue().isPercent;
                                if(obj[count].CurrentDiscounts != response.getReturnValue().CurrentDiscounts) {
                                    obj[count].CurrentDiscounts = response.getReturnValue().CurrentDiscounts;
                                }
                                obj[count].minDiscountPercent = response.getReturnValue().minDiscountPercent;
                                obj[count].maxDiscountPercent = response.getReturnValue().maxDiscountPercent;
                                obj[count].discountPercent = response.getReturnValue().discountPercent;
                                obj[count].discountName = response.getReturnValue().discountName;
                               //var dn = response.getReturnValue().discountName;
                                //alert(dn);
                                
                                var diss = JSON.stringify(response.getReturnValue().CurrentDiscounts);
                               // alert(diss);
                                
                               // alert(obj[count].discountName);
                                if(obj[count].discountName === '') obj[count].minDiscountPercent = 0;
                                if(obj[count].discountName === '') obj[count].maxDiscountPercent = 0;
                                if(obj[count].discountName === '') obj[count].discountName = "";
                              //  alert(obj[count].discountName);
                            }
                        }
                        cmp.set("v.ProductsAndDiscountsWrapperListt", obj);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                });
                $A.enqueueAction(action);
            }
        //} catch(err) {
        //alert("Exception : "+err.message);
        //}
    },
    
    EndDateGiven: function(cmp, event) {
        try{
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var count = event.getSource().get("v.labelClass");
            var obj = cmp.get("v.ProductsAndDiscountsWrapperListt");
            var objsel;
            for(var x in obj){
                if(x == count) { 
                    objsel = obj[count];
                }
            }
        
            //Validate the dates
            var action = cmp.get("c.getCharge");
            action.setParams({
                objsel: JSON.stringify(objsel)
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    var res = response.getReturnValue();
                    //alert(res.quantity_s);
                    objsel.quantity_s = res.quantity_s;
                    obj[count] = objsel;
                    //AddDiscount
                    //cmp.set("v.ProductsAndDiscountsWrapperListt", obj);
                    var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
                    var SalesOrder2Creates = cmp.get("v.SalesOrder");
                    var Customers = new Array(cmp.get("v.Customer"));
                    var Contacts = new Array(cmp.get("v.Contact"));
                    var SOP = cmp.get("v.SOP");
                    var isBackorder = (SalesOrder2Creates.ERP7__Is_Back_Order__c == true)? true : false;
                    var actions = cmp.get("c.DiscountPlans");
                    actions.setParams({
                        itemId: objsel.product.Id,
                        currentSalepoints1: JSON.stringify(currentSalepoints),
                        isBackorder: isBackorder, 
                        Customers1: JSON.stringify(Customers),
                        Contacts1: JSON.stringify(Contacts),
                        SOP: SOP,
                        quantity_s: objsel.quantity_s,
                        Version: objsel.Version
                    });
                    
                    actions.setCallback(this, function(response) {
                        var state = response.getState();
                        //alert(state);
                        if (state === "SUCCESS") {
                            cmp.set("v.ProductsAndDiscountsWrapperListt", '');
                            for(var x in obj){
                                if(x == count) { 
                                    //obj[count] = response.getReturnValue();
                                    obj[count].quantity_s = response.getReturnValue().quantity_s;
                                    
                                    if(obj[count].CurrentDiscounts != response.getReturnValue().CurrentDiscounts) {
                                        obj[count].CurrentDiscounts = response.getReturnValue().CurrentDiscounts;
                                        
                                    }
                                    obj[count].minDiscountPercent = response.getReturnValue().minDiscountPercent;
                                    obj[count].maxDiscountPercent = response.getReturnValue().maxDiscountPercent;
                                    obj[count].discountPercent = response.getReturnValue().discountPercent;
                                    obj[count].discountName = response.getReturnValue().discountName;
                                    var diss = JSON.stringify(response.getReturnValue().CurrentDiscounts);
                                    if(obj[count].discountName === '') obj[count].minDiscountPercent = 0;
                                    if(obj[count].discountName === '') obj[count].maxDiscountPercent = 0;
                                    if(obj[count].discountName === '') obj[count].discountName = "";
                                    //alert(obj[count].discountName);
                                }
                            }
                            cmp.set("v.ProductsAndDiscountsWrapperListt", obj);
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }
                    });
                    $A.enqueueAction(actions);
                }
            });
            $A.enqueueAction(action);
        
        } catch(err) {
            //alert("Exception : "+err.message);
        }
    },
    
    EndDateGivenEdit : function(cmp, event) {
        try{
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var count = event.getSource().get("v.labelClass");
            //var value = event.getSource().get("v.value");
            //alert(value);
            var obj = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
            var objsel;
            for(var x in obj){
                if(x == count) { 
                    objsel = obj[count];
                }
            }
        
            //Validate the dates
            var action = cmp.get("c.getCharge");
            action.setParams({
                objsel: JSON.stringify(objsel)
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    var res = response.getReturnValue();
                    //alert(res.quantity_s);
                    objsel.quantity_s = res.quantity_s;
                    obj[count] = objsel;
                    //AddDiscountEdit
                    //cmp.set("v.ProductsAndDiscountsWrapperListtEdit", obj);
                    var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
                    var SalesOrder2Creates = cmp.get("v.SalesOrder");
                    var Customers = new Array(cmp.get("v.Customer"));
                    var Contacts = new Array(cmp.get("v.Contact"));
                    var SOP = cmp.get("v.SOP");
                    var isBackorder = (SalesOrder2Creates.ERP7__Is_Back_Order__c == true)? true : false;
                    
                    var actions = cmp.get("c.DiscountPlans");
                    actions.setParams({
                        itemId: objsel.product.Id,
                        currentSalepoints1: JSON.stringify(currentSalepoints),
                        isBackorder: isBackorder, 
                        Customers1: JSON.stringify(Customers),
                        Contacts1: JSON.stringify(Contacts),
                        SOP: SOP,
                        quantity_s: objsel.quantity_s,
                        Version: objsel.Version
                    });
                    
                    actions.setCallback(this, function(response) {
                        var state = response.getState();
                        //alert(state);
                        if (state === "SUCCESS") {
                            cmp.set("v.ProductsAndDiscountsWrapperListtEdit", '');
                            for(var x in obj){
                                if(x == count) { 
                                    obj[count].quantity_s = response.getReturnValue().quantity_s;
                                    
                                    if(obj[count].CurrentDiscounts != response.getReturnValue().CurrentDiscounts) obj[count].CurrentDiscounts = response.getReturnValue().CurrentDiscounts;
                                    obj[count].minDiscountPercent = response.getReturnValue().minDiscountPercent;
                                    obj[count].maxDiscountPercent = response.getReturnValue().maxDiscountPercent;
                                    obj[count].discountPercent = response.getReturnValue().discountPercent;
                                    obj[count].discountName = response.getReturnValue().discountName;
                                    
                                    if(obj[count].discountName === '') obj[count].minDiscountPercent = 0;
                                    if(obj[count].discountName === '') obj[count].maxDiscountPercent = 0;
                                }
                            }
                            cmp.set("v.ProductsAndDiscountsWrapperListtEdit", obj);
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }
                    });
                    $A.enqueueAction(actions);
                }
            });
            $A.enqueueAction(action);
        
        } catch(err) {
            alert("Exception : "+err.message);
        }
    },
    
    VersionChange : function(cmp, event) {
        var count = event.getSource().get("v.labelClass");
        var obj = cmp.get("v.ProductsAndDiscountsWrapperListt");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count];
            }
        }
        
        var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
        var SOP = cmp.get("v.SOP");
        var action = cmp.get("c.VersionsChange");
        action.setParams({
            currentSalepoints1: JSON.stringify(currentSalepoints),
            SOP: SOP,
            Version: objsel.Version
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                for(var x in obj){
                    if(x == count) { 
                        var pro = obj[x];
                        obj[x].product_Type = 'N/A';
                        var stk = response.getReturnValue().Value;
                        obj[x].stock = stk;
                        if(obj[x].quantity_s > parseFloat(pro.stock)) obj[x].quantity_s = stk;
                        if(Boolean(pro.trackInventory) || Boolean(pro.product.ERP7__Is_Asset__c)){
                            /*Inventory Product*/
                            if(Boolean(pro.product.ERP7__Is_Asset__c)){
                                /*Rental Product*/
                                
                                if(pro.stock !='' && pro.stock != undefined && parseFloat(pro.stock) > 0){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = pro.stock;
                                }else{
                                    obj[x].product_Type = (pro.stock === undefined)?0:pro.stock;
                                }
                                
                            }else{
                                /*Non Rental Product*/
                                if(pro.stock !='' && pro.stock != undefined && pro.stock > 0){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = pro.stock;
                                }   
                                else if(Boolean(pro.product.ERP7__Allow_Back_Orders__c)){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = 'Back-Order';
                                }
                                else if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = 'Pre-Order';
                                }
                                else{
                                    obj[x].product_Type = (pro.stock === undefined)?0:pro.stock;
                                }
                            }  
                        }else{
                            /*Non Inventory Product*/
                            if(Boolean(pro.product.ERP7__Is_Kit__c)){
                                /*Kit Product*/
                                obj[x].showcbox = true;
                                obj[x].product_Type = 'Kit';
                                if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                    obj[x].product_Type = 'Kit (Pre-Order)';
                                }
                                else if(Boolean(pro.product.ERP7__Allow_Back_Orders__c)){
                                    obj[x].product_Type = 'Kit (Back-Order)';
                                } 
                            }
                            /*Non Kit Product*/   
                            else if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                obj[x].product_Type = 'Pre-Order';
                                obj[x].showcbox = true;
                            }
                            else if(pro.product.ERP7__Status__c === 'Released'){
                                    obj[x].product_Type = pro.product.ERP7__Item_Type__c;
                                    obj[x].showcbox = true;
                             }    
                        }
                    
                        //if(response.getReturnValue().Error != true) obj[count].stock = response.getReturnValue().Value;
                        //alert(obj[count].product_Type);
                        
                    }
                }
                cmp.set("v.ProductsAndDiscountsWrapperListt", obj);
            }
        });
        $A.enqueueAction(action);
    },
    
    /*VersionChanged : function(cmp, event) {
        var count = event.getSource().get("v.labelClass");
        var obj = cmp.get("v.ProductsAndDiscountsWrapperListt");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count];
            }
        }
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");        
        var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
        var SalesOrder2Creates = cmp.get("v.SalesOrder");
        var Customers = new Array(cmp.get("v.Customer"));
        var Contacts = new Array(cmp.get("v.Contact"));
        var SOP = cmp.get("v.SOP");
        var isBackorder = (SalesOrder2Creates.ERP7__Is_Back_Order__c == true)? true : false;
        if(objsel.quantity_s == "") objsel.quantity_s = 0;
        
        var action = cmp.get("c.VersionsChanged");
        action.setParams({
            itemId: objsel.product.Id,
            currentSalepoints: currentSalepoints,
            isBackorder: isBackorder, 
            Customers: Customers,
            Contacts: Contacts,
            SOP: SOP,
            quantity_s: objsel.quantity_s,
            Version: objsel.Version
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                for(var x in obj){
                    if(x == count) { 
                        var mypro = response.getReturnValue();
                        var pro = obj[x];
                        obj[x].product_Type = 'N/A';
                        var stk = mypro.stock;
                        obj[x].stock = stk;
                        obj[x].pricebookEntry = mypro.pricebookEntry;
                        obj[x].pricebookEntry.Id = mypro.pricebookEntry.Id;
                        //alert(obj[x].pricebookEntry.Id);
                        if(obj[x].quantity_s > parseFloat(pro.stock)) obj[x].quantity_s = stk;
                        if(Boolean(pro.trackInventory) || Boolean(pro.product.ERP7__Is_Asset__c)){
                            //Inventory Product
                            if(Boolean(pro.product.ERP7__Is_Asset__c)){
                                //Rental Product
                                
                                if(pro.stock !='' && pro.stock != undefined && parseFloat(pro.stock) > 0){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = pro.stock;
                                }else{
                                    obj[x].product_Type = (pro.stock === undefined)?0:pro.stock;
                                }
                                
                            }else{
                                //Non Rental Product
                                if(pro.stock !='' && pro.stock != undefined && pro.stock > 0){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = pro.stock;
                                }   
                                else if(Boolean(pro.product.ERP7__Allow_Back_Orders__c)){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = 'Back-Order';
                                }
                                else if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = 'Pre-Order';
                                }
                                else{
                                    obj[x].product_Type = (pro.stock === undefined)?0:pro.stock;
                                }
                            }  
                        }else{
                            //Non Inventory Product
                            if(Boolean(pro.product.ERP7__Is_Kit__c)){
                                //Kit Product
                                obj[x].showcbox = true;
                                obj[x].product_Type = 'Kit';
                                if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                    obj[x].product_Type = 'Kit (Pre-Order)';
                                }
                                else if(Boolean(pro.product.ERP7__Allow_Back_Orders__c)){
                                    obj[x].product_Type = 'Kit (Back-Order)';
                                } 
                            }
                            //Non Kit Product  
                            else if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                obj[x].product_Type = 'Pre-Order';
                                obj[x].showcbox = true;
                            }
                            else if(pro.product.ERP7__Status__c === 'Released'){
                                    obj[x].product_Type = pro.product.ERP7__Item_Type__c;
                                    obj[x].showcbox = true;
                             }    
                        }
                    
                        //if(response.getReturnValue().Error != true) obj[count].stock = response.getReturnValue().Value;
                        //alert(obj[count].product_Type);
                        
                    }
                }
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                cmp.set("v.ProductsAndDiscountsWrapperListt", obj);
            }
        });
        $A.enqueueAction(action);
    },*/
    
    discountPercents : function(cmp, event) {
        var count = event.getSource().get("v.labelClass");
        var obj = cmp.get("v.ProductsAndDiscountsWrapperListt");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count];
            }
        }
        
        if(objsel.discountName != '' && objsel.discountName != '--None--'){
            var action = cmp.get("c.discountPercent");
            action.setParams({
                discountName: objsel.discountName
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    for(var x in obj){
                        if(x == count) { 
                            //alert(response.getReturnValue().ERP7__Default_Discount_Percentage__c);
                            //alert(response.getReturnValue().ERP7__Default_Discount_Value__c);
                            if(response.getReturnValue().ERP7__Default_Discount_Percentage__c != undefined){
                                obj[count].minDiscountPercent = response.getReturnValue().ERP7__Floor_Discount_Percentage__c;
                                obj[count].maxDiscountPercent = response.getReturnValue().ERP7__Ceiling_Discount_Percentage__c;
                                if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)){
                                    obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Percentage__c;
                                    obj[count].isPercent = true;
                                }
                            } 
                            else if(response.getReturnValue().ERP7__Default_Discount_Value__c != undefined){
                                obj[count].minDiscountPercent = response.getReturnValue().ERP7__Floor_Discount_Value__c;
                                obj[count].maxDiscountPercent = response.getReturnValue().ERP7__Ceiling_Discount_Value__c;
                                if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)){
                                    obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Value__c; 
                                    obj[count].isPercent = false;
                                }
                            }
                        }
                    }
                    cmp.set("v.ProductsAndDiscountsWrapperListt", obj);
                }
            });
            $A.enqueueAction(action);
        } else{
            for(var x in obj){
                if(x == count) { 
                    obj[count].minDiscountPercent = 0;
                    obj[count].maxDiscountPercent = 0;
                    obj[count].discountPercent = 0.00;
                    var flag= true;
                    var arr = cmp.find("discountPer");
                    if(cmp.find("discountPer") != undefined){
                        for(var i in cmp.find("discountPer")){
                            if(arr[i].getElement().parentElement.name == count)
                                arr[i].set("v.errors",null);
                            if(arr[i].get("v.errors") != null && arr[i].get("v.errors") != undefined)
                            if(arr[i].get("v.errors").length>0)
                                flag = false;
                        }
                    }

                        if(flag) cmp.find("addButton").set("v.disabled",false); 
                    break;
                }
            }
            cmp.set("v.ProductsAndDiscountsWrapperListt", obj);
        }
    },
    DeleteRecordById :  function(cmp, event, helper){
        var count = cmp.get("v.lineItemTOdelete");
        var obj = cmp.get("v.itemWrapperListt");
        var item2delete =  obj[count];
        var SalesOrder2Create = cmp.get("v.SalesOrder");
        if(item2delete.orderLineItemId != ''){
            var delAction  = cmp.get("c.deleteSoliById");
            delAction.setParams({"SoliId":item2delete.orderLineItemId});
            delAction.setCallback(this,function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    if(response.getReturnValue() != '')
                        cmp.set("v.exceptionError",response.getReturnValue());
                    else{
                        obj.splice(count, 1);
                        cmp.popInit();
                        $A.util.toggleClass(cmp.find("deleteModal"),"slds-hide");
                    }
                    
                }
            });
            $A.enqueueAction(delAction);
        }else{
            obj.splice(count, 1);
            var subTotal = 0;
            var discounts = 0;
            var taxes = 0.00;
            var totalDue = 0;
            
            var finalDue = 0;
            var allItems = obj; //cmp.get("v.itemWrapperListt");
            
            //alert('2');
            for(var z in allItems){
                subTotal = subTotal + parseFloat(allItems[z].price);
                taxes = taxes + parseFloat(allItems[z].vat) + parseFloat(allItems[z].tax);
                discounts = discounts + parseFloat(allItems[z].discount);
            }
            totalDue = subTotal + taxes - discounts;
            finalDue = totalDue; //- loyaltyAmount;
            if(SalesOrder2Create.ERP7__Amount_Paid__c != undefined) finalDue = finalDue - parseFloat(SalesOrder2Create.ERP7__Amount_Paid__c);
            if(SalesOrder2Create.ERP7__Shipping_Discount__c != undefined) finalDue = finalDue + parseFloat(SalesOrder2Create.ERP7__Shipping_Discount__c);
            if(SalesOrder2Create.ERP7__Total_Shipping_Amount__c != undefined) finalDue = finalDue + parseFloat(SalesOrder2Create.ERP7__Total_Shipping_Amount__c);
            finalDue = finalDue.toFixed(2);
            //alert('3');
            cmp.set("v.subTotal",subTotal);
            cmp.set("v.taxes",taxes);
            cmp.set("v.discounts",discounts);
            cmp.set("v.totalDue",totalDue);
            cmp.set("v.finalDue",finalDue);
            $A.util.toggleClass(cmp.find("deleteModal"),"slds-hide");
        }   
        cmp.set("v.itemWrapperListt", obj);

    },
    hideDeletePopup :function(cmp, event, helper){ $A.util.toggleClass(cmp.find("deleteModal"),"slds-hide");},
    
    removeItem : function(cmp, event) {
        var target = event.getSource();
        var count = event.getSource().get("v.name");
        
        cmp.set("v.lineItemTOdelete",parseInt(count));
        $A.util.toggleClass(cmp.find("deleteModal"),"slds-hide");
    },
    
    NewProduct: function(cmp, event) {
        var spop = cmp.get("v.SerialPopup");
        var bpop = cmp.get("v.BatchPopup");
        if(spop) {
            cmp.set("v.SerialPopup", false);
        }
        if(bpop) {
            cmp.set("v.BatchPopup", false);
        }
        var ik = [];
        cmp.set("v.pdLists", ik);
        window.scrollTo(0, 0);
    },
    
    NewProductPopup: function(cmp, event, helper) {
        cmp.set("v.SerialPopup", false);
        cmp.set("v.BatchPopup", false);
        var ik = [];
        cmp.set("v.pdLists", ik);
        window.scrollTo(0, 0);
        var obList = cmp.get("v.ProductsAndDiscountsWrapperListt");
        if(obList.length == 0){
            //cmp.set("v.productLimit",10);
            //cmp.fetchProductNew();
            try{
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
                var SalesOrder2Creates = new Array(cmp.get("v.SalesOrder"));
                var isBackOrders = SalesOrder2Creates[0].ERP7__Is_Back_Order__c;
                var isPreOrders = SalesOrder2Creates[0].ERP7__Is_Pre_Order__c;
                if(isBackOrders != true) isBackOrders = false;
                if(isPreOrders != true) isPreOrders = false;
                var Customers = new Array(cmp.get("v.Customer"));
                var Contacts = new Array(cmp.get("v.Contact"));
                var i = cmp.get("v.itemName");
                var j = cmp.get("v.prodFam");
                var k = cmp.get("v.SOP");
                var l = cmp.get("v.itemWrapperListt");
                cmp.set("v.productLimit",10);
                var productLimit = cmp.get("v.productLimit");
                var IsRental = cmp.get("v.IsRental");
                var ExpectedDate = SalesOrder2Creates[0].ERP7__Expected_Date__c;
                var action = cmp.get("c.productFetchss");
                action.setParams({
                    itemName: cmp.get("v.itemName"),
                    ProdFam: cmp.get("v.prodFam"),
                    ProdCat: cmp.get("v.prodCat"),
                    ProdSubCat: cmp.get("v.prodSubCat"),
                    currentSalepoints1: JSON.stringify(currentSalepoints),
                    Customers1: JSON.stringify(Customers),
                    Contacts1: JSON.stringify(Contacts),
                    SOP: cmp.get("v.SOP"),
                    itemWrapperList: JSON.stringify(cmp.get("v.itemWrapperListt")),
                    isBackOrder: isBackOrders,
                    isPreOrder: isPreOrders,
                    ExpectedDate: ExpectedDate,
                    productLimit: productLimit
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var obj = response.getReturnValue();
                        var objEdit = new Array();
                        for(var x in obj){
                            var pro = obj[x];
                            obj[x].product_Type = 'N/A';
                            if(Boolean(pro.trackInventory) || Boolean(pro.product.ERP7__Is_Asset__c)){
                                /*Inventory Product*/
                                if(Boolean(pro.product.ERP7__Is_Asset__c)){
                                    /*Rental Product*/
                                    
                                    if(pro.stock !='' && pro.stock != undefined && parseFloat(pro.stock) > 0){
                                        obj[x].showcbox = true;
                                        obj[x].product_Type = pro.stock;
                                    }else{
                                        obj[x].product_Type = (pro.stock === undefined)?0:pro.stock;
                                    }
                                    
                                }else{
                                    /*Non Rental Product*/
                                    if(pro.stock !='' && pro.stock != undefined && pro.stock > 0){
                                        obj[x].showcbox = true;
                                        obj[x].product_Type = pro.stock;
                                    }   
                                    else if(Boolean(pro.product.ERP7__Allow_Back_Orders__c)){
                                        obj[x].showcbox = true;
                                        obj[x].product_Type = 'Back-Order';
                                    }
                                    else if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                        obj[x].showcbox = true;
                                        obj[x].product_Type = 'Pre-Order';
                                    }
                                    else{
                                        obj[x].product_Type = (pro.stock === undefined)?0:pro.stock;
                                    }
                                }  
                            }else{
                                /*Non Inventory Product*/
                                if(Boolean(pro.product.ERP7__Is_Kit__c)){
                                    /*Kit Product*/
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = 'Kit';
                                }
                                /*Non Kit Product*/   
                                else if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                    obj[x].product_Type = 'Pre-Order';
                                    obj[x].showcbox = true;
                                }
                                 else if(pro.product.ERP7__Status__c === 'Released'){
                                        obj[x].product_Type = pro.product.ERP7__Item_Type__c;
                                        obj[x].showcbox = true;
                                 }    
                            }
                           
                            objEdit.push(obj[x]);
                        }
                        cmp.set("v.ProductsAndDiscountsWrapperListt", objEdit);
                        var objEditN = cmp.get("v.ProductsAndDiscountsWrapperListt");
                        cmp.set("v.ProductsAndDiscountsWrapperListt", objEditN);
                        cmp.set("v.pdLists", new Array());
                        if(cmp.get("v.SerialPopup")) {
                            cmp.set("v.SerialPopup",false);
                        }
                    }
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            } catch(err) {
                //alert('fetchProduct ==> Exception Occured '+err);
            }
        }
        $A.util.addClass(cmp.find("addProductModal"), 'slds-fade-in-open');
        $A.util.addClass(cmp.find("addProductsBackdrop"), 'slds-fade-in-open');
    },
    
    closeEditProduct : function (cmp, event) {        
        $A.util.removeClass(cmp.find("editProductModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("editProductsBackdrop"), 'slds-fade-in-open');
    },
    
    editItem : function(cmp, event) {
        $A.util.addClass(cmp.find("editProductModal"), 'slds-fade-in-open');
        $A.util.addClass(cmp.find("editProductsBackdrop"), 'slds-fade-in-open');
        try{
            var ik = [];
            cmp.set("v.pdLists", ik);
            var objEdit = new Array();
            var count = event.getSource().get("v.name");
            cmp.set("v.editCount",count); 
            var sopi =  cmp.get("v.SOP");
            var cs =  cmp.get("v.currentSalepoint");
            var so =  cmp.get("v.SalesOrder");
            var cus =  cmp.get("v.Customer");
            var con =  cmp.get("v.Contact");
            var obj = cmp.get("v.itemWrapperListt");
            
            var productIdi, discountIdi = '';
            var quantity_si, discounti = 0;
            if(obj[count].product.Id != '') productIdi = obj[count].product.Id;
            if(obj[count].discountId != '') discountIdi = obj[count].discountId;
            //alert(obj[count].quantity_s);
            quantity_si = obj[count].quantity_s;
            discounti = obj[count].discountPercent;
            if(obj[count].product.ERP7__Serialise__c){
                cmp.set("v.SerialPopup", true);
            } else cmp.set("v.SerialPopup", false);
            if(!obj[count].product.ERP7__Serialise__c && obj[count].product.ERP7__Lot_Tracked__c){
                cmp.set("v.BatchPopup", true);
            } else cmp.set("v.BatchPopup", false);
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
            var SalesOrder2Creates = cmp.get("v.SalesOrder");
            var Customers = new Array(cmp.get("v.Customer"));
            var Contacts = new Array(cmp.get("v.Contact"));
            var isBackorder = (SalesOrder2Creates.ERP7__Is_Back_Order__c == true)? true : false;    
            var action = cmp.get("c.editProducts");
            action.setParams({
                itemId: productIdi,
                quants: quantity_si,
                discountId: discountIdi,
                discount: discounti,
                currentSalepoints1: JSON.stringify(currentSalepoints),
                isBackorder: isBackorder, 
                Customers1: JSON.stringify(Customers),
                Contacts1: JSON.stringify(Contacts),
                SOP: sopi,
                Version: obj[count].Version
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                   
                    objEdit.push(response.getReturnValue()[0]);
                   
                    if(obj[count].lineitm.ERP7__Price_Product__c != '' && obj[count].lineitm.ERP7__Price_Product__c != undefined) objEdit[0].pricebookEntry.UnitPrice = obj[count].lineitm.ERP7__Price_Product__c;
                    if(obj[count].lineitm.ERP7__Detailed_Description__c != '' && obj[count].lineitm.ERP7__Detailed_Description__c != undefined) objEdit[0].product.Description = obj[count].lineitm.ERP7__Detailed_Description__c;
                    objEdit[0].EndTime = obj[count].EndTime;
                    objEdit[0].SerialNos = obj[count].SerialNos;
                    objEdit[0].Batches = obj[count].Batches;
                    //objEdit[0].allBatchesStock = obj[count].allBatchesStock;
                    var allBatchesStock = 0;
                    for(var z in obj[count].Batches){
                        allBatchesStock += obj[count].Batches[z].ERP7__Available_Quantity__c;
                    }
                    objEdit[0].allBatchesStock = allBatchesStock;
                    //SelectedProduct.allBatchesStock
                    //resolve edit issue
                    cmp.set("v.ProductsAndDiscountsWrapperListtEdit", response.getReturnValue());
                    //alert(obj[count].product.ERP7__Serialise__c); 
                    
                    if(obj[count].product.ERP7__Serialise__c){
                       var actions = cmp.get("c.getSerialNos");
                        actions.setParams({
                            currentSalepoints1: JSON.stringify(currentSalepoints),
                    Customers1: JSON.stringify(Customers),
                            objsel: JSON.stringify(objEdit[0]),
                            SerialNumber: ""
                        });
                        
                        actions.setCallback(this, function(response) {
                            var state = response.getState();
                            //alert(state);
                            if (state === "SUCCESS") {
                                var res = response.getReturnValue();
                                //alert(res.length);
                                for(var x in res){
                                    res[x].product = objEdit[0].product;
                                    res[x].pricebookEntry = objEdit[0].pricebookEntry;
                                }
                                cmp.set("v.pdLists", res);
                                cmp.set("v.IsRental", objEdit[0].product.ERP7__Is_Asset__c);
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            }
                        });
                        $A.enqueueAction(actions);
                    } 
                    
                    if(!obj[count].product.ERP7__Serialise__c && obj[count].product.ERP7__Lot_Tracked__c){
                        var action = cmp.get("c.getBatchNos");
                        action.setParams({
                            currentSalepoints1: JSON.stringify(currentSalepoints),
                    Customers1: JSON.stringify(Customers),
                            objsel: JSON.stringify(objEdit[0]),
                            BatchNumber: ""
                        });
                        
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            //alert(state);
                            if (state === "SUCCESS") {
                                var res = response.getReturnValue();
                                for(var x in res){
                                    res[x].product = objEdit[0].product;
                                    res[x].pricebookEntry = objEdit[0].pricebookEntry;
                                }
                                cmp.set("v.pdLists", res);
                                cmp.set("v.IsRental", objEdit[0].product.ERP7__Is_Asset__c);
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            }
                        });
                        $A.enqueueAction(action);
                    }
                    /*
                    if(obj[count].product.ERP7__Serialise__c){
                        cmp.set("v.IsRental", objEdit[0].product.ERP7__Is_Asset__c);
                        cmp.set("v.SerialPopup", true);
                    }*/
                    else{
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        cmp.set("v.IsRental", objEdit[0].product.ERP7__Is_Asset__c);
                    }
                }
            });
            $A.enqueueAction(action);
            window.scrollTo(0, 0);
        }
        catch(err) {
            alert("Exception : "+err.message);
        }
        
    },
    
    
    closeDescripionModal : function(cmp, event) {
        $A.util.removeClass(cmp.find('ProductDescriptionModal'),'slds-fade-in-open');
    },
    
    descriptionGet : function(cmp, event) {
        $A.util.addClass(cmp.find('ProductDescriptionModal'),'slds-fade-in-open');
        try{
            var count = event.getSource().get("v.name");
            var obj = cmp.get("v.itemWrapperListt"); 
            var desn = '';
            for(var x in obj){
                if(count == x) { 
                    desn = obj[x].prod_Desc;
                }
            }
            cmp.set("v.prodDescription", desn);
            cmp.set("v.editCount", count);
            window.scrollTo(0, 0);
        }
        catch(err) {
            //alert("Exception : "+err.message);
        }
        
    },
    
    descriptionSet : function(cmp, event) {
        try{
            var count = cmp.get("v.editCount");
            var obj = cmp.get("v.itemWrapperListt"); 
            for(var x in obj){
                if(x == count) { 
                    obj[x].prod_Desc = cmp.get("v.prodDescription");
                    ////alert(obj[x].product.Name);
                }
            }
            //cmp.set("v.itemWrapperListt[count].prod_Desc", obj[count].prod_Desc);
            //$('#myModal1').modal('hide');
            $A.util.removeClass(cmp.find('ProductDescriptionModal'),'slds-fade-in-open');
            
        }
        catch(err) {
            //alert("Exception : "+err.message);
        }
        
    },
    
    addDiscountEdit : function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var count = event.getSource().get("v.labelClass");
        var obj = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count];
            }
        }
        if(objsel.product.ERP7__Serialise__c && !objsel.product.ERP7__Is_Asset__c && objsel.SerialNos.length > objsel.quantity_s){
            objsel.quantity_s = objsel.SerialNos.length;
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        else{
            var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
            var SalesOrder2Creates = cmp.get("v.SalesOrder");
            var Customers = new Array(cmp.get("v.Customer"));
            var Contacts = new Array(cmp.get("v.Contact"));
            var SOP = cmp.get("v.SOP");
            var isBackorder = (SalesOrder2Creates.ERP7__Is_Back_Order__c == true)? true : false;
            if(objsel.quantity_s == "") objsel.quantity_s = 0;
            
            var action = cmp.get("c.DiscountPlans");
            action.setParams({
                itemId: objsel.product.Id,
                currentSalepoints1: JSON.stringify(currentSalepoints),
                isBackorder: isBackorder, 
                Customers1: JSON.stringify(Customers),
                Contacts1: JSON.stringify(Contacts),
                SOP: SOP,
                quantity_s: objsel.quantity_s,
                Version: objsel.Version
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    cmp.set("v.ProductsAndDiscountsWrapperListtEdit", '');
                    for(var x in obj){
                        if(x == count) { 
                            obj[count].quantity_s = response.getReturnValue().quantity_s;
                            obj[count].isPercent = response.getReturnValue().isPercent;
                            if(obj[count].CurrentDiscounts != response.getReturnValue().CurrentDiscounts) obj[count].CurrentDiscounts = response.getReturnValue().CurrentDiscounts;
                            obj[count].minDiscountPercent = response.getReturnValue().minDiscountPercent;
                            obj[count].maxDiscountPercent = response.getReturnValue().maxDiscountPercent;
                            obj[count].discountPercent = response.getReturnValue().discountPercent;
                            //var dn = response.getReturnValue().discountName;
                            //alert(dn);
                            
                            //var diss = JSON.stringify(response.getReturnValue().CurrentDiscounts);
                            //alert(diss);
                            obj[count].discountName = response.getReturnValue().discountName;
                            //alert(obj[count].discountName);
                            if(obj[count].discountName == '') obj[count].minDiscountPercent = 0;
                            if(obj[count].discountName == '') obj[count].maxDiscountPercent = 0;
                            
                            }
                    }
                    cmp.set("v.ProductsAndDiscountsWrapperListtEdit", obj);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    discountPercentsEdit : function(cmp, event) {
        var count = event.getSource().get("v.labelClass");
        
        var obj = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
        var objsel;
        for(var x in obj){
            if(count == x) { 
                objsel = obj[count];
                
            }
        }
        if(objsel.discountName != '' && objsel.discountName != '--None--'){
            var action = cmp.get("c.discountPercent");
            action.setParams({
                discountName: objsel.discountName
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    for(var x in obj){
                        if(x == count) { 
                            //alert(response.getReturnValue().ERP7__Default_Discount_Percentage__c);
                            //alert(response.getReturnValue().ERP7__Default_Discount_Value__c);
                            if(response.getReturnValue().ERP7__Default_Discount_Percentage__c != undefined){
                                obj[count].minDiscountPercent = response.getReturnValue().ERP7__Floor_Discount_Percentage__c;
                                obj[count].maxDiscountPercent = response.getReturnValue().ERP7__Ceiling_Discount_Percentage__c;
                                if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)){
                                    obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Percentage__c;
                                    obj[count].isPercent = true;
                                }
                            } 
                            else if(response.getReturnValue().ERP7__Default_Discount_Value__c != undefined){
                                obj[count].minDiscountPercent = response.getReturnValue().ERP7__Floor_Discount_Value__c;
                                obj[count].maxDiscountPercent = response.getReturnValue().ERP7__Ceiling_Discount_Value__c;
                                if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)){
                                    obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Value__c; 
                                    obj[count].isPercent = false;
                                }
                            }
                        }
                    }
                    cmp.set("v.ProductsAndDiscountsWrapperListtEdit", obj);
                }
            });
            $A.enqueueAction(action);
        } else{
            for(var x in obj){
                if(x == count) { 
                    obj[count].minDiscountPercent = 0;
                    obj[count].maxDiscountPercent = 0;
                    obj[count].discountPercent = 0.00;
                    //var flag= true;
                    //var arr = cmp.find("editDiscountper");
                    //arr[0].set("v.errors",null);
                    cmp.find("editUpdate").set("v.disabled",false); 
                    break;
                }
            }
            cmp.set("v.ProductsAndDiscountsWrapperListtEdit", obj);
        }
    },
    
    closeAddProductsModal : function(cmp, event){
        cmp.set('v.itemName','');
        cmp.set('v.prodFam','');
        cmp.set('v.prodCat','');
        cmp.set('v.prodSubCat','');
        $A.util.removeClass(cmp.find("addProductModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("addProductsBackdrop"), 'slds-fade-in-open');
    },
    
    addItems : function (cmp, event) {
        var obj = cmp.get("v.ProductsAndDiscountsWrapperListt");
        var loyaltyPoints = cmp.get("v.loyaltyPoints");
        var loyaltyAmount = cmp.get("v.loyaltyAmount");
        var SalesOrder2Create = cmp.get("v.SalesOrder");
        var objsel = new Array();
        var objNew = new Array();
        for(var x in obj){
            if(obj[x].selected == true) { 
                objsel.push(obj[x]);
            } 
            else { var kk = obj[x]; objNew.push(kk); }
            
        }
        
        if(objsel.length == 0){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Warning',
                    'type': 'warning',
                    'mode': 'dismissable',
                    'message': 'Please select Items to add'
                });
                toastEvent.fire();
        }
        if(objsel.length > 0){
            for(var i=0;i<objsel.length;i++){
                if(objsel[i].quantity_s == 0){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Warning',
                        'type': 'warning',
                        'mode': 'dismissable',
                        'message': 'Please select quantity for '+objsel[i].product.Name
                    });
                    toastEvent.fire();
                    return;
                }
            }
        }
        var objselstring = JSON.stringify(objsel);
        var il = obj.length;
        while (il--) {
            if(obj[il].selected == true){ 
                //var ilk = obj[il].SerialNos.length;
                //while (ilk--) obj[il].SerialNos.splice(ilk, 1);
                obj.splice(il, 1);
            }
        }
        var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
        var SalesOrder2Creates = new Array(cmp.get("v.SalesOrder"));
        var SalesOrder2Createss = JSON.stringify(cmp.get("v.SalesOrder"));
        var Customers = new Array(cmp.get("v.Customer"));
        var Contacts = new Array(cmp.get("v.Contact"));
        var baddr = cmp.get("v.bAdd");
        var saddr = cmp.get("v.sAdd");
       
        if(objsel.length > 0){
            var action = cmp.get("c.addProducts2");
            action.setParams({
                selWrap: objselstring,
                currentSalepoints1: JSON.stringify(currentSalepoints),
                Customers1: JSON.stringify(Customers),
                Contacts1: JSON.stringify(Contacts),
                SOP: cmp.get("v.SOP"),
                TaxRate :cmp.get("v.TaxRate"),
                Serials2Delete: cmp.get("v.Serials2Delete"),
                SalesOrder2Creates: SalesOrder2Createss,
                BA: baddr,
                SA: saddr
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert('Add Items');
                if (state === "SUCCESS") {
                    try {
                        var objItems = cmp.get("v.itemWrapperListt");
                        var myallitems = new Array();  
                        for(var y in objItems){
                            myallitems.push(objItems[y]);                   
                        }
                        for(var y in response.getReturnValue()){
                            myallitems.push(response.getReturnValue()[y]);                  
                        }
                        for(var y in response.getReturnValue()){
                            if(response.getReturnValue()[y].Serial.Id != undefined) myallitems[myallitems.length-1].SerialNos.push(response.getReturnValue()[y].Serial);
                        }
                        var subTotal = 0;
                        var discounts = 0;
                        var taxes = 0.00;
                        var totalDue = 0;
                        
                        var finaldue = 0;
                        var allItems = myallitems;//cmp.get("v.itemWrapperListt");
                        
                        for(var z in allItems){
                            subTotal = subTotal + parseFloat(allItems[z].price);
                            taxes = taxes + parseFloat(allItems[z].vat) + parseFloat(allItems[z].tax);
                            discounts = discounts + parseFloat(allItems[z].discount);
                        }
                        totalDue = subTotal + taxes - discounts;
                        finaldue = totalDue; //- loyaltyAmount;
                        if(SalesOrder2Create.ERP7__Amount_Paid__c != undefined) finaldue = finaldue - parseFloat(SalesOrder2Create.ERP7__Amount_Paid__c);
                        if(SalesOrder2Create.ERP7__Shipping_Discount__c != undefined) finaldue = finaldue + parseFloat(SalesOrder2Create.ERP7__Shipping_Discount__c);
                        if(SalesOrder2Create.ERP7__Total_Shipping_Amount__c != undefined) finaldue = finaldue + parseFloat(SalesOrder2Create.ERP7__Total_Shipping_Amount__c);
                        finaldue = finaldue.toFixed(2);
                        var dumitems = new Array();
                        cmp.set("v.ProductsAndDiscountsWrapperListt",obj);
                        cmp.set("v.itemWrapperListt",myallitems);
                        cmp.set("v.subTotal",subTotal);
                        cmp.set("v.taxes",taxes);
                        cmp.set("v.discounts",discounts);
                        cmp.set("v.totalDue",totalDue);
                        cmp.set("v.finalDue",finaldue);
                        cmp.set('v.itemName','');
                        cmp.set('v.prodFam','');
                        cmp.set('v.prodCat','');
                        cmp.set('v.prodSubCat','');
                        $A.util.removeClass(cmp.find("addProductModal"), 'slds-fade-in-open');
                        $A.util.removeClass(cmp.find("addProductsBackdrop"), 'slds-fade-in-open');
                        
                    }
                    catch(err) { 
                        //alert("Exception : "+err.message);
                        console.log('err.message :'+err.message);
                    }
                }
            });
            $A.enqueueAction(action);
             
        }
    },
    
    assignEndDate: function (cmp, event) {
        var count = event.getSource().get("v.labelClass");
        var obj = cmp.get("v.pdLists");
        var objNew = cmp.get("v.ProductsAndDiscountsWrapperListt");
        for(var x in obj){
            if(x == count) { 
                if(obj[x].StartTime != undefined && obj[x].StartTime != '' && obj[x].EndTime != undefined && obj[x].EndTime != ''){
                    var st = new Date(obj[x].StartTime);
                    var en = new Date(obj[x].EndTime);
                    if(en.getTime() < st.getTime()){
                        obj[x].EndTime = obj[x].StartTime;
                    }
                }
            } 
        }
        cmp.set("v.pdLists",obj);
    },
    
    assign : function (cmp, event) {
        var count = event.getSource().get("v.labelClass");
        var obj = cmp.get("v.pdLists");
        var CountHolder = cmp.get("v.CountHolder");
        var objNew = cmp.get("v.ProductsAndDiscountsWrapperListt");
        if(objNew.SerialNos == undefined) objNew.SerialNos = new Array();
        
        for(var x in obj){
            if(x == count) { 
                //alert(obj[x].StartTime);
                //alert(obj[x].EndTime);
                if(obj[x].StartTime != undefined && obj[x].EndTime != undefined && obj[x].StartTime != '' && obj[x].EndTime != ''){
                    var st = new Date(obj[x].StartTime);
                    var et = new Date(obj[x].EndTime);
                    var stn = st.toISOString().slice(0,10);
                    var etn = et.toISOString().slice(0,10);
                    obj[x].Serial.ERP7__Start_Date__c = stn;
                    obj[x].Serial.ERP7__End_Date__c = etn;
                } else {
                    obj[x].Serial.ERP7__Start_Date__c = undefined;
                    obj[x].Serial.ERP7__End_Date__c = undefined;
                }
                objNew[CountHolder].SerialNos.push(obj[x].Serial);
            } 
        }
        obj.splice(count, 1);
        cmp.set("v.pdLists",obj);
        cmp.set("v.ProductsAndDiscountsWrapperListt",objNew);
        cmp.set("v.SelectedProduct",objNew[CountHolder]);
        //alert('Add Assets');
        //Take selected serial nos and add to SO line items
        /*SerialNos
        var count = event.getSource().get("v.labelClass");
        var obj = cmp.get("v.pdLists");
        var loyaltyPoints = cmp.get("v.loyaltyPoints");
        var loyaltyAmount = cmp.get("v.loyaltyAmount");
        var SalesOrder2Create = cmp.get("v.SalesOrder");
        var objsel = new Array();
        var objNew = new Array();
        var iks = JSON.stringify(obj);
        //alert(iks);
        for(var x in obj){
            //alert(obj[x].selected);
            if(x == count) { 
                //alert('found');
                //var pbe = obj[x].pricebookentry.Selling_Price__c;
                //alert(pbe);
                objsel.push(obj[x]);
            } 
            else { var kk = obj[x]; objNew.push(kk); }
        }
       
        obj.splice(count, 1);
        var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
        //var SalesOrder2Creates = new Array(cmp.get("v.SalesOrder"));
        var Customers = new Array(cmp.get("v.Customer"));
        var Contacts = new Array(cmp.get("v.Contact"));
        if(objsel.length > 0){
            //alert(JSON.stringify(objsel));
            //alert(currentSalepoints[0].Id);
            //alert(Customers[0].Id);
            //alert(Contacts[0].Id);
            var sop = cmp.get("v.SOP");
            //alert(sop);
            var TaxRate = cmp.get("v.TaxRate");
            //alert(TaxRate);
            var action = cmp.get("c.Assignment");
            action.setParams({
                selWrap: JSON.stringify(objsel),
                currentSalepoints: currentSalepoints,
                Customers: Customers,
                Contacts: Contacts,
                SOP: sop,
                TaxRate :TaxRate
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state)
                if (state === "SUCCESS") {
                    try {
                        var objItems = cmp.get("v.itemWrapperListt");
                        var myallitems = new Array();  
                        for(var y in objItems){
                            myallitems.push(objItems[y]); 
                        }
                        for(var y in response.getReturnValue()){
                            myallitems.push(response.getReturnValue()[y]);
                            break;
                        }
                        for(var y in response.getReturnValue()){
                            //alert(response.getReturnValue()[y].Serial.Name);
                            myallitems[myallitems.length-1].SerialNos.push(response.getReturnValue()[y].Serial);
                        }
                        
                        var subTotal = 0;
                        var discounts = 0;
                        var taxes = 0.00;
                        var totalDue = 0;
                        
                        var finaldue = 0;
                        var allItems = myallitems;//cmp.get("v.itemWrapperListt");
                        
                        for(var z in allItems){
                            subTotal = subTotal + parseFloat(allItems[z].price);
                            taxes = taxes + parseFloat(allItems[z].vat) + parseFloat(allItems[z].tax);
                            discounts = discounts + parseFloat(allItems[z].discount);
                        }
                        totalDue = subTotal + taxes - discounts;
                        finaldue = totalDue; //- loyaltyAmount;
                        if(SalesOrder2Create.Amount_Paid__c != null) finaldue = finaldue + parseFloat(SalesOrder2Create.Amount_Paid__c);
                        var dumitems = new Array();
                        
                        //cmp.set("v.ProductsAndDiscountsWrapperListt",objNew);
                        $('#myModal').modal('hide');
                        cmp.set("v.itemWrapperListt",myallitems);
                        cmp.set("v.subTotal",subTotal);
                        cmp.set("v.taxes",taxes);
                        cmp.set("v.discounts",discounts);
                        cmp.set("v.totalDue",totalDue);
                        cmp.set("v.finalDue",finaldue);
                        cmp.set("v.pdLists",obj);
                    }
                    catch(err) {
                        //alert("Exception : "+err.message);
                    }
                }
            });
            $A.enqueueAction(action);
            
        }*/
    },
    
    assignBatch : function (cmp, event) {
        var count = event.getSource().get("v.labelClass");
        var obj = cmp.get("v.pdLists");
        var CountHolder = cmp.get("v.CountHolder");
        var objNew = cmp.get("v.ProductsAndDiscountsWrapperListt");
        if(objNew.Batches == undefined) objNew.Batches = new Array();
        
        for(var x in obj){
            if(x == count) { 
                objNew[CountHolder].Batches.push(obj[x].Batch);
            } 
        }
        objNew[CountHolder].allBatchesStock = 0;
        for(var x in objNew[CountHolder].Batches){
            if(objNew[CountHolder].Batches[x].ERP7__Available_Quantity__c != undefined) objNew[CountHolder].allBatchesStock += objNew[CountHolder].Batches[x].ERP7__Available_Quantity__c;
        }
        obj.splice(count, 1);
        cmp.set("v.pdLists",obj);
        cmp.set("v.ProductsAndDiscountsWrapperListt",objNew);
        cmp.set("v.SelectedProduct",objNew[CountHolder]);
    },
    
    assignBatchEdit : function (cmp, event) {
        var count = event.getSource().get("v.labelClass");
        var obj = cmp.get("v.pdLists");
        var CountHolder = cmp.get("v.CountHolder");
        var objNew = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
        if(objNew.Batches == undefined) objNew.Batches = new Array();
        
        for(var x in obj){
            if(x == count) { 
                objNew[0].Batches.push(obj[x].Batch);
            } 
        }
        objNew[0].allBatchesStock = 0;
        for(var x in objNew[0].Batches){
            if(objNew[0].Batches[x].ERP7__Available_Quantity__c != undefined) objNew[0].allBatchesStock += objNew[0].Batches[x].ERP7__Available_Quantity__c;
        }
        obj.splice(count, 1);
        cmp.set("v.pdLists",obj);
        cmp.set("v.ProductsAndDiscountsWrapperListtEdit",objNew);
        cmp.set("v.SelectedProduct",objNew[0]);
    },
    
    removeSerialNew : function (cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var count = event.getSource().get("v.title");
        var subcount = event.getSource().get("v.name");
        var objSel = cmp.get("v.ProductsAndDiscountsWrapperListt");
        var CountHolder = cmp.get("v.CountHolder");
        //alert(count);
        //alert(subcount);
        if(CountHolder == count){
            var res = new Object();//objSel[count];
            res.Serial = objSel[count].SerialNos[subcount];
            if(res.Serial.ERP7__Asset__c != undefined && res.Serial.ERP7__Asset__c != null){
                res.Serial.ERP7__Asset__r.ERP7__Available__c = true;
                res.Serial.ERP7__Asset__r.ERP7__Status__c = 'Available';
                if(res.Serial.ERP7__Start_Date__c != undefined && res.Serial.ERP7__Start_Date__c != '' && res.Serial.ERP7__End_Date__c != undefined && res.Serial.ERP7__End_Date__c != ''){
                    //var s = '01-01-1970 00:03:44';
                    //var e = '01-01-1970 00:03:44';
                    res.StartTime = res.Serial.ERP7__Start_Date__c;
                    res.EndTime = res.Serial.ERP7__End_Date__c;
                }
            }
            var pnds = cmp.get("v.pdLists");
            pnds.push(res);
            cmp.set("v.pdLists", pnds);            
        }
        objSel[count].SerialNos.splice(subcount, 1);
        cmp.set("v.ProductsAndDiscountsWrapperListt",objSel);
        if(CountHolder == count) cmp.set("v.SelectedProduct", objSel[CountHolder]);
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        //alert('count : '+count);
        //alert('subcount : '+subcount);
    },
    
    removeBatchNew : function (cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var count = event.getSource().get("v.title");
        var subcount = event.getSource().get("v.name");
        var objSel = cmp.get("v.ProductsAndDiscountsWrapperListt");
        var CountHolder = cmp.get("v.CountHolder");
        //alert(count);
        //alert(subcount);
        if(CountHolder == count){
            var res = new Object();//objSel[count];
            res.Batch = objSel[count].Batches[subcount];
            var pnds = cmp.get("v.pdLists");
            pnds.push(res);
            cmp.set("v.pdLists", pnds);            
        }
        objSel[count].Batches.splice(subcount, 1);
        objSel[count].allBatchesStock = 0;
        for(var x in objSel[count].Batches){
            if(objSel[count].Batches[x].ERP7__Available_Quantity__c != undefined) objSel[count].allBatchesStock += objSel[count].Batches[x].ERP7__Available_Quantity__c;
        }
        cmp.set("v.ProductsAndDiscountsWrapperListt",objSel);
        if(CountHolder == count) cmp.set("v.SelectedProduct", objSel[CountHolder]);
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        //alert('count : '+count);
        //alert('subcount : '+subcount);
    },
    
    removeBatchNewEdit : function (cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var count = 0;
        var subcount = event.getSource().get("v.name");
        var objSel = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
        
        var res = new Object();//objSel[count];
        res.Batch = objSel[count].Batches[subcount];
        var pnds = cmp.get("v.pdLists");
        pnds.push(res);
        cmp.set("v.pdLists", pnds);            
        
        objSel[count].Batches.splice(subcount, 1);
        objSel[count].allBatchesStock = 0;
        for(var x in objSel[count].Batches){
            if(objSel[count].Batches[x].ERP7__Available_Quantity__c != undefined) objSel[count].allBatchesStock += objSel[count].Batches[x].ERP7__Available_Quantity__c;
        }
        cmp.set("v.ProductsAndDiscountsWrapperListtEdit",objSel);
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
    },
    
    assignEdit : function (cmp, event) {
        var count = event.getSource().get("v.labelClass");
        var obj = cmp.get("v.pdLists");
        var iks = JSON.stringify(obj);
        var objSel = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
        var il = obj.length;
        /*while (il--) {
            if(obj[il].selected == true)  {
                objSel[objSel.length-1].SerialNos.push(obj[il].Serial);
                obj.splice(il, 1);
            }
        }*/
        for(var x in obj){
            if(x == count) { 
                if(obj[x].StartTime != undefined && obj[x].EndTime != undefined && obj[x].StartTime != '' && obj[x].EndTime != ''){
                    var st = new Date(obj[x].StartTime);
                    var et = new Date(obj[x].EndTime);
                    var stn = st.toISOString().slice(0,10);
                    var etn = et.toISOString().slice(0,10);
                    obj[x].Serial.ERP7__Start_Date__c = stn;
                    obj[x].Serial.ERP7__End_Date__c = etn;
                } else {
                    obj[x].Serial.ERP7__Start_Date__c = undefined;
                    obj[x].Serial.ERP7__End_Date__c = undefined;
                }
                objSel[objSel.length-1].SerialNos.push(obj[x].Serial);
            } 
        }
        obj.splice(count, 1);
        cmp.set("v.ProductsAndDiscountsWrapperListtEdit",objSel);
        cmp.set("v.pdLists",obj);
    },
    
    updateItem : function (cmp, event) {
        
        var objsel = new Array();
        var obj = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
        var objItems = cmp.get("v.itemWrapperListt");
        var loyaltyPoints = cmp.get("v.loyaltyPoints");
        var loyaltyAmount = cmp.get("v.loyaltyAmount");
        var SalesOrder2Create = cmp.get("v.SalesOrder");
        var SalesOrder2Creates = JSON.stringify(SalesOrder2Create);
        for(var x in obj){
            var kkk = obj[x];
            if(kkk != undefined && kkk != "") objsel.push(kkk);
        }
        
        var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
        //var SalesOrder2Creates = new Array(cmp.get("v.SalesOrder"));
        var Customers = new Array(cmp.get("v.Customer"));
        var Contacts = new Array(cmp.get("v.Contact"));
        var baddr = cmp.get("v.bAdd");
        var saddr = cmp.get("v.sAdd");
        if(objsel.length > 0){
            var ikik = JSON.stringify(objsel);
          
            var action = cmp.get("c.addProducts2");
            action.setParams({
                selWrap: JSON.stringify(objsel),
                currentSalepoints1: JSON.stringify(currentSalepoints),
                Customers1: JSON.stringify(Customers),
                Contacts1: JSON.stringify(Contacts),
                SOP: cmp.get("v.SOP"),
                TaxRate:cmp.get("v.TaxRate"),
                Serials2Delete: cmp.get("v.Serials2Delete"),
                SalesOrder2Creates: SalesOrder2Creates,
                BA: baddr,
                SA: saddr
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
         
                if (state === "SUCCESS") {
                    try {
                        var myobjset = new Array();
                        var sliceCount;
                        var found = false;
                        var editCount = cmp.get("v.editCount");
                        
                        for(var y in objItems){
                            if(y == editCount){   
                                found = true;
                                var osid = objItems[y].orderLineItemId;
                                objItems[y] = response.getReturnValue()[0];
                                objItems[y].orderLineItemId = osid;
                                objItems[y].SerialNos =  obj[0].SerialNos;
                            } 
                        } 
                        var subTotal = 0;
                        var discounts = 0;
                        var taxes = 0;
                        var totalDue = 0;
                        
                        var finalDue = 0;
                        var allItems = objItems;//cmp.get("v.itemWrapperListt");
                        
                        for(var z in allItems){
                            subTotal = subTotal + parseFloat(allItems[z].price);
                            taxes = taxes + parseFloat(allItems[z].vat) + parseFloat(allItems[z].tax);
                            discounts = discounts + parseFloat(allItems[z].discount);
                        }
                        totalDue = subTotal + taxes - discounts;
                        finalDue = totalDue - loyaltyAmount;
                        
                        if(SalesOrder2Create.ERP7__Amount_Paid__c != undefined) finalDue = finalDue - parseFloat(SalesOrder2Create.ERP7__Amount_Paid__c);
                        if(SalesOrder2Create.ERP7__Shipping_Discount__c != undefined) finalDue = finalDue + parseFloat(SalesOrder2Create.ERP7__Shipping_Discount__c);
                        if(SalesOrder2Create.ERP7__Total_Shipping_Amount__c != undefined) finalDue = finalDue + parseFloat(SalesOrder2Create.ERP7__Total_Shipping_Amount__c);
                        finalDue = finalDue.toFixed(2);
                        //$('#myModale').modal('hide');
                        $A.util.removeClass(cmp.find("editProductModal"), 'slds-fade-in-open');
                        $A.util.removeClass(cmp.find("editProductsBackdrop"), 'slds-fade-in-open');
                        cmp.set("v.subTotal",subTotal);
                        cmp.set("v.taxes",taxes);
                        cmp.set("v.discounts",discounts);
                        cmp.set("v.totalDue",totalDue);
                        cmp.set("v.finalDue",finalDue);
                        cmp.set("v.itemWrapperListt",objItems);
                        
                        var objsetBlank = new Array();
                        cmp.set("v.ProductsAndDiscountsWrapperListtEdit",objsetBlank);
                    }
                    catch(err) {
                        //alert("Exception : "+err.message);
                        console.log('Exception : '+err.message);
                    }
                }
            });
            $A.enqueueAction(action);
            
        }
        
    },
    
    draftSave : function (cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var li2d = cmp.get("v.lineItem2delete");   
        var sonId = '';
        var coms = cmp.get("v.itemWrapperListt");
        
        if(cmp.get("v.Mtask") != null && cmp.get("v.Mtask") != undefined && cmp.get("v.Mtask") != ""){
            var task = cmp.get("v.Mtask");
            cmp.set("v.SalesOrder.ERP7__Tasks__c", task.Id);
            cmp.set("v.SalesOrder.ERP7__Project__c", task.ERP7__Project__c);
            
        }
        
        //alert('Coms length : ',coms.length);
        var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
        var baddr = cmp.get("v.bAdd");
        var saddr = cmp.get("v.sAdd");
        var SO = cmp.get("v.SalesOrder");
        
        //cmp.set("v.orderStatus", response.getReturnValue().Order.ERP7__Status__c); 
        SO.ERP7__Status__c = cmp.get("v.orderStatus");
        
        SO.ERP7__Bill_To_Address__c = baddr;
        SO.ERP7__Ship_To_Address__c = saddr;
        
        var currentEmployee = cmp.get("v.currentEmployee");
        var currentAccount = cmp.get("v.Customer");
        if(currentEmployee.Id == undefined || currentAccount.Id == undefined){
            cmp.set("v.exceptionError",'Required fields are missing');
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        else {
            cmp.set("v.exceptionError",'');
            SO.ERP7__Employees__c = currentEmployee.Id;
            var SalesOrder2Creates = JSON.stringify(SO);
           
            var loyaltyPoints = cmp.get("v.loyaltyPoints");
            var loyaltyAmount = cmp.get("v.loyaltyAmount");
            var Customers = new Array(cmp.get("v.Customer"));
            var Contacts = new Array(cmp.get("v.Contact"));
            var AccProfile1 = cmp.get("v.AccProfile1");
            var AccTax1 = cmp.get("v.AccTax1");
            Customers[0].ERP7__Account_Profile__c = AccProfile1.Id;
            Customers[0].ERP7__VAT__c = AccTax1.Id;
    		var error = false; 
           
            if(JSON.stringify(Contacts) == '[{}]' || Contacts[0].Id==''){
               
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!",
                    "type":"warning",
                    "message": "Please select Contact."
                });
                toastEvent.fire();
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                return;
            }
            if(cmp.get('v.sAdd') == undefined || cmp.get('v.bAdd') == undefined){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!",
                    "type":"warning",
                    "message": "Please select Billing and Shipping address."
                });
                toastEvent.fire();
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                return;
            }
            
            
            if(coms.length > 0 || SO.Name != undefined){
                var action = cmp.get("c.saveDrafts");
                action.setParams({
                    selWrap: JSON.stringify(coms),
                    currentSalepoints1: JSON.stringify(currentSalepoints),
                    SalesOrder2Creates: SalesOrder2Creates, 
                    Customers1: JSON.stringify(Customers),
                    Contacts1: JSON.stringify(Contacts),
                    SOP: cmp.get("v.SOP"),
                    lineItem2delete: cmp.get("v.lineItem2delete"),
                    invoiceName: cmp.get("v.Invoice.Name"),
                    loyaltyPoints: loyaltyPoints,
                    loyaltyAmount: loyaltyAmount,
                    Serials2Delete: cmp.get("v.Serials2Delete")
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        if(response.getReturnValue().Error == false){
                            cmp.set("v.exceptionError",'');
                            sonId = response.getReturnValue().Value;
                            cmp.set("v.SON",sonId);
                            cmp.set("v.CON","");
                        	cmp.set("v.CUST","");  
                            //var kk = cmp.get("v.proceed");
                            cmp.set("v.proceed",true);
                            cmp.popInit();
                        } else if(response.getReturnValue().Error == true){
                            cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }
                        //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }else if (response.getState() === "ERROR") {
                        console.log('Error:',response.getError());
                        var errors = response.getError();
                        if(errors[0] && errors[0].pageErrors) {
                            cmp.set("v.exceptionError",errors[0].pageErrors[0].message);
                        }
                        //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }else{
                        console.log('Error:',response.getError());
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                cmp.set("v.exceptionError",'Please add Product(s) before saving.');
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
        }  
    },
    
    draftSaveShipment : function (cmp, event) {
        
        var li2d = cmp.get("v.lineItem2delete");   
        var sonId = '';
        var coms = cmp.get("v.itemWrapperListt");
        var currentSalepoints = new Array(cmp.get("v.currentSalepoint"));
        var baddr = cmp.get("v.bAdd");
        var saddr = cmp.get("v.sAdd");
        var SO = cmp.get("v.SalesOrder");        
        SO.ERP7__Bill_To_Address__c = baddr;
        SO.ERP7__Ship_To_Address__c = saddr;
        var SalesOrder2Creates = JSON.stringify(SO);
        
        var loyaltyPoints = cmp.get("v.loyaltyPoints");
        var loyaltyAmount = cmp.get("v.loyaltyAmount");
        var Customers = new Array(cmp.get("v.Customer"));
        var Contacts = new Array(cmp.get("v.Contact"));
        
        if(coms.length > 0 || SO.Name != undefined){
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.saveDrafts");
            action.setParams({
                selWrap: JSON.stringify(coms),
                currentSalepoints1: JSON.stringify(currentSalepoints),
                SalesOrder2Creates: SalesOrder2Creates, 
                Customers1: JSON.stringify(Customers),
                Contacts1: JSON.stringify(Contacts),
                SOP: cmp.get("v.SOP"),
                lineItem2delete: cmp.get("v.lineItem2delete"),
                invoiceName: cmp.get("v.Invoice.Name"),
                loyaltyPoints: loyaltyPoints,
                loyaltyAmount: loyaltyAmount,
                Serials2Delete: cmp.get("v.Serials2Delete")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    sonId = response.getReturnValue();
                    cmp.set("v.SON",sonId);
                    cmp.set("v.proceed",true);
                    $A.util.removeClass(cmp.find("myModalSOShipment"),"slds-fade-in-open");
                    $A.util.removeClass(cmp.find("myModalSOShipmentBackdrop"),"slds-backdrop_open");
                    cmp.popInit();
                }
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            });
            $A.enqueueAction(action);
        }else{
            cmp.set("v.shipError",'Sales Order not found');
        }  
    },
    
    /*
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    },
    
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();    
    },
    */
    
    validatevalue :  function (cmp, event, helper) {
        var count = event.getSource().get("v.labelClass");
        var obj = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
        var objsel;
        for(var x in obj){
            if(count == x) { 
                objsel = obj[count];
                break;
            }
        }
        if(objsel.discountName != '' && objsel.discountName != '--None--'){
            var action = cmp.get("c.discountPercent");
            action.setParams({
                discountName: objsel.discountName
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    for(var x in obj){
                        if(x == count) { 
                            if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)){
                                obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Percentage__c;
                                //if(objsel.isPercent) target.set("v.errors",[{message:"% must be b/w limits"}]);
                                //else target.set("v.errors",[{message:"Value must be b/w limits"}]);
                                //cmp.find("editUpdate").set("v.disabled",true); 
                        }
                            else{
                                //target.set("v.errors",'');
                                //cmp.find("editUpdate").set("v.disabled",false);
                            }
                                //obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Percentage__c;  
                        }
                    }
                    cmp.set("v.ProductsAndDiscountsWrapperListtEdit", obj);
                }
            });
            $A.enqueueAction(action);
        } else{
            //target.set("v.errors",'');
            //cmp.find("editUpdate").set("v.disabled",false);
            for(var x in obj){
                if(x == count) { 
                    obj[count].minDiscountPercent = 0;
                    obj[count].maxDiscountPercent = 0;
                    obj[count].discountPercent = 0.00;
                    obj[count].discountName = '';
                    obj[count].discount = 0;
                    
                }
            }
            cmp.set("v.ProductsAndDiscountsWrapperListtEdit", obj);
        }

        
    },
    addvalidatevalue : function(cmp, event) {
        var target = event.getSource();
        var count = event.getSource().get("v.labelClass");
       
        var obj = cmp.get("v.ProductsAndDiscountsWrapperListt");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count]; 
            }
        }
        
        if(objsel.discountName != '' && objsel.discountName != '--None--'){
            var action = cmp.get("c.discountPercent");
            action.setParams({
                discountName: objsel.discountName
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    for(var x in obj){
                        if(x == count) { 
                            //alert(response.getReturnValue().ERP7__Default_Discount_Percentage__c);
                            //alert(response.getReturnValue().ERP7__Default_Discount_Value__c);
                            if(response.getReturnValue().ERP7__Default_Discount_Percentage__c != undefined){
                                obj[count].minDiscountPercent = response.getReturnValue().ERP7__Floor_Discount_Percentage__c;
                                obj[count].maxDiscountPercent = response.getReturnValue().ERP7__Ceiling_Discount_Percentage__c;
                                if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)){
                                    obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Percentage__c;
                                    obj[count].isPercent = true;
                                }
                            } 
                            else if(response.getReturnValue().ERP7__Default_Discount_Value__c != undefined){
                                obj[count].minDiscountPercent = response.getReturnValue().ERP7__Floor_Discount_Value__c;
                                obj[count].maxDiscountPercent = response.getReturnValue().ERP7__Ceiling_Discount_Value__c;
                                if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)){
                                    obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Value__c; 
                                    obj[count].isPercent = false;
                                }
                            }
                           
                            if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)) {
                                obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Percentage__c;
                                //if(objsel.isPercent) target.set("v.errors",[{message:"% must be b/w limits"}]);
                                //else target.set("v.errors",[{message:"Value must be b/w limits"}]);
                                //cmp.find("addButton").set("v.disabled",true); 
                            }else{
                                //target.set("v.errors",null);
                                //cmp.find("addButton").set("v.disabled",false); 
                                
                            }
                        }
                    }
                    cmp.set("v.ProductsAndDiscountsWrapperListt", obj);
                }
            });
            $A.enqueueAction(action);
        } else{
             //target.set("v.errors",null);
             //cmp.find("addButton").set("v.disabled",false); 
            for(var x in obj){
                if(x == count) { 
                    obj[count].minDiscountPercent = 0;
                    obj[count].maxDiscountPercent = 0;
                    obj[count].discountPercent = 0.00;
                    
                }
            }
            cmp.set("v.ProductsAndDiscountsWrapperListt", obj);
        }
    },
    addvalidatevaluek : function(cmp, event) {
        var target = event.getSource();
        var count = event.getSource().get("v.labelClass");
       
        var obj = cmp.get("v.ProductsAndDiscountsWrapperListt");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count]; 
            }
        }
        
        if(objsel.discountName != '' && objsel.discountName != '--None--'){
            if(objsel.discountPercent != undefined && objsel.discountPercent != ""){
                var action = cmp.get("c.discountPercent");
                action.setParams({
                    discountName: objsel.discountName
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        for(var x in obj){
                            if(x == count) { 
                                //alert(response.getReturnValue().ERP7__Default_Discount_Percentage__c);
                                //alert(response.getReturnValue().ERP7__Default_Discount_Value__c);
                                if(response.getReturnValue().ERP7__Default_Discount_Percentage__c != undefined){
                                    obj[count].minDiscountPercent = response.getReturnValue().ERP7__Floor_Discount_Percentage__c;
                                    obj[count].maxDiscountPercent = response.getReturnValue().ERP7__Ceiling_Discount_Percentage__c;
                                    if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)){
                                        obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Percentage__c;
                                        obj[count].isPercent = true;
                                    }
                                } 
                                else if(response.getReturnValue().ERP7__Default_Discount_Value__c != undefined){
                                    obj[count].minDiscountPercent = response.getReturnValue().ERP7__Floor_Discount_Value__c;
                                    obj[count].maxDiscountPercent = response.getReturnValue().ERP7__Ceiling_Discount_Value__c;
                                    if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)){
                                        obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Value__c; 
                                        obj[count].isPercent = false;
                                    }
                                }
                               
                                if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)) {
                                    obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Percentage__c;
                                    //if(objsel.isPercent) target.set("v.errors",[{message:"% must be b/w limits"}]);
                                    //else target.set("v.errors",[{message:"Value must be b/w limits"}]);
                                    //cmp.find("addButton").set("v.disabled",true); 
                                }else{
                                    //target.set("v.errors",null);
                                    //cmp.find("addButton").set("v.disabled",false); 
                                    
                                }
                            }
                        }
                        cmp.set("v.ProductsAndDiscountsWrapperListt", obj);
                    }
                });
                $A.enqueueAction(action);
            }
        } else{
             //target.set("v.errors",null);
             //cmp.find("addButton").set("v.disabled",false); 
            for(var x in obj){
                if(x == count) { 
                    obj[count].minDiscountPercent = 0;
                    obj[count].maxDiscountPercent = 0;
                    obj[count].discountPercent = 0.00;
                    
                }
            }
            cmp.set("v.ProductsAndDiscountsWrapperListt", obj);
        }
    },
    editvalidatevalue : function(cmp, event) {
        var target = event.getSource();
        var count = event.getSource().get("v.labelClass");
       
        var obj = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count]; 
            }
        }
        
        if(objsel.discountName != '' && objsel.discountName != '--None--'){
            var action = cmp.get("c.discountPercent");
            action.setParams({
                discountName: objsel.discountName
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    for(var x in obj){
                        if(x == count) { 
                            //alert(response.getReturnValue().ERP7__Default_Discount_Percentage__c);
                            //alert(response.getReturnValue().ERP7__Default_Discount_Value__c);
                            if(response.getReturnValue().ERP7__Default_Discount_Percentage__c != undefined){
                                obj[count].minDiscountPercent = response.getReturnValue().ERP7__Floor_Discount_Percentage__c;
                                obj[count].maxDiscountPercent = response.getReturnValue().ERP7__Ceiling_Discount_Percentage__c;
                                if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)){
                                    obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Percentage__c;
                                    obj[count].isPercent = true;
                                }
                            } 
                            else if(response.getReturnValue().ERP7__Default_Discount_Value__c != undefined){
                                obj[count].minDiscountPercent = response.getReturnValue().ERP7__Floor_Discount_Value__c;
                                obj[count].maxDiscountPercent = response.getReturnValue().ERP7__Ceiling_Discount_Value__c;
                                if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)){
                                    obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Value__c; 
                                    obj[count].isPercent = false;
                                }
                            }
                           
                            if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)) {
                                obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Percentage__c;
                                //if(objsel.isPercent) target.set("v.errors",[{message:"% must be b/w limits"}]);
                                //else target.set("v.errors",[{message:"Value must be b/w limits"}]);
                                //cmp.find("addButton").set("v.disabled",true); 
                            }else{
                                //target.set("v.errors",null);
                                //cmp.find("addButton").set("v.disabled",false); 
                                
                            }
                        }
                    }
                    cmp.set("v.ProductsAndDiscountsWrapperListtEdit", obj);
                }
            });
            $A.enqueueAction(action);
        } else{
             //target.set("v.errors",null);
             //cmp.find("addButton").set("v.disabled",false); 
            for(var x in obj){
                if(x == count) { 
                    obj[count].minDiscountPercent = 0;
                    obj[count].maxDiscountPercent = 0;
                    obj[count].discountPercent = 0.00;
                    
                }
            }
            cmp.set("v.ProductsAndDiscountsWrapperListtEdit", obj);
        }
    },
    editvalidatevaluek : function(cmp, event) {
        var target = event.getSource();
        var count = event.getSource().get("v.labelClass");
       
        var obj = cmp.get("v.ProductsAndDiscountsWrapperListtEdit");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count]; 
            }
        }
        
        if(objsel.discountName != '' && objsel.discountName != '--None--'){
            if(objsel.discountPercent != undefined && objsel.discountPercent != ""){
                var action = cmp.get("c.discountPercent");
                action.setParams({
                    discountName: objsel.discountName
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        for(var x in obj){
                            if(x == count) { 
                                //alert(response.getReturnValue().ERP7__Default_Discount_Percentage__c);
                                //alert(response.getReturnValue().ERP7__Default_Discount_Value__c);
                                if(response.getReturnValue().ERP7__Default_Discount_Percentage__c != undefined){
                                    obj[count].minDiscountPercent = response.getReturnValue().ERP7__Floor_Discount_Percentage__c;
                                    obj[count].maxDiscountPercent = response.getReturnValue().ERP7__Ceiling_Discount_Percentage__c;
                                    if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)){
                                        obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Percentage__c;
                                        obj[count].isPercent = true;
                                    }
                                } 
                                else if(response.getReturnValue().ERP7__Default_Discount_Value__c != undefined){
                                    obj[count].minDiscountPercent = response.getReturnValue().ERP7__Floor_Discount_Value__c;
                                    obj[count].maxDiscountPercent = response.getReturnValue().ERP7__Ceiling_Discount_Value__c;
                                    if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)){
                                        obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Value__c; 
                                        obj[count].isPercent = false;
                                    }
                                }
                               
                                if(!(objsel.discountPercent >= obj[count].minDiscountPercent && objsel.discountPercent <= obj[count].maxDiscountPercent)) {
                                    obj[count].discountPercent = response.getReturnValue().ERP7__Default_Discount_Percentage__c;
                                    //if(objsel.isPercent) target.set("v.errors",[{message:"% must be b/w limits"}]);
                                    //else target.set("v.errors",[{message:"Value must be b/w limits"}]);
                                    //cmp.find("addButton").set("v.disabled",true); 
                                }else{
                                    //target.set("v.errors",null);
                                    //cmp.find("addButton").set("v.disabled",false); 
                                    
                                }
                            }
                        }
                        cmp.set("v.ProductsAndDiscountsWrapperListtEdit", obj);
                    }
                });
                $A.enqueueAction(action);
            }
        } else{
             //target.set("v.errors",null);
             //cmp.find("addButton").set("v.disabled",false); 
            for(var x in obj){
                if(x == count) { 
                    obj[count].minDiscountPercent = 0;
                    obj[count].maxDiscountPercent = 0;
                    obj[count].discountPercent = 0.00;
                    
                }
            }
            cmp.set("v.ProductsAndDiscountsWrapperListtEdit", obj);
        }
    },
    
    goBackTask : function(component, event, helper) {
       
        $A.createComponent("c:AddMilestoneTask",{
            "aura:id" : "taskCmp",
            "projectId" : component.get("v.projectId"),
            "taskId" : component.get("v.Mtask.Id"),
            "newTask" : component.get("v.Mtask"),
            "currentMilestones" : component.get("v.currentMilestones"),
            "currentProject" : component.get("v.currentProject")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    enableButton:function(cmp){
        var flag= true;
        var arr = cmp.find("discountPer");
        for(var x in cmp.find("discountPer")){
            if(arr[x].get("v.errors") != null && arr[x].get("v.errors") != undefined){
                
                if(arr[x].get("v.errors").length>0)
                    flag = false;
            }
        }
       if(flag) cmp.find("addButton").set("v.disabled",false); 
        
    },
    
    CreatePO:function(component, event, helper){
        var soliId = event.currentTarget.getAttribute('data-recordId');
       
        $A.createComponent("c:CreatePurchaseOrder",{
            "soliID":soliId,
            "cancelclick":component.getReference("c.backSO")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
            var body = component.find("body");
            body.set("v.body", newCmp);
        }
        });
    },
    
    CreatePR:function(component, event, helper){
        var soliId = event.currentTarget.getAttribute('data-recordId');       
        $A.createComponent("c:CreatePurchaseRequisition",{
            "soliID":soliId,
            "cancelclick":component.getReference("c.backOC")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
            var body = component.find("body");
            body.set("v.body", newCmp);
        }
        });
    },
    
    backOC : function(component,event,helper){
       var so = component.get("v.SalesOrder.Id");
       
       $A.createComponent("c:OrderConsole",{
           "SON" :so
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
        }
        }); 
    },
    
    backSO : function(component,event,helper){
       var so = component.get("v.SalesOrder.Id");
     
       $A.createComponent("c:OrderConsole",{
           "SON" :so
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
        }
        }); 
    },
    
    CreateWO : function(cmp, event, helper) {
        var SOLI = event.currentTarget.getAttribute('data-soliId');
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        var URL_RMA = '/apex/ERP7__WorkOrderLC?soliId='+SOLI;//?soliId='+SOLI+'&so='+SalesOrder[0].Id;
        window.open(URL_RMA,'_blank');
        /*
        var SOLI = event.currentTarget.getAttribute('data-soliId');  
       
        $A.createComponent("c:Work_Orders",{
            "soliID":SOLI,
            "cancelclick":cmp.getReference("c.backSO")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
            var body = cmp.find("body");
            body.set("v.body", newCmp);
        }
        });*/
    },
    
    CreateMO : function(cmp, event, helper) { 
        var SOLI = event.currentTarget.getAttribute('data-mosoliId');
       
       /* $A.createComponent("c:Manufacturing_Orders",{
            "mosoliId":soliId,
            "cancelclick":cmp.getReference("c.backSO")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
            var body = cmp.find("body");
            body.set("v.body", newCmp);
        }
        });*/
        var URL_RMA = '/apex/ERP7__ManufacturingOrderLC?mosoliId='+SOLI+'&soliId='+SOLI;
        //var URL_RMA = '/lightning/n/ERP7__Manufacturing_Order?mosoliId='+SOLI;
        window.open(URL_RMA,'_blank');
        
        /*var SOLI = event.currentTarget.getAttribute('data-mosoliId');
        var RecUrl = "/apex/ERP7__ManufacturingOrderLC?mosoliId="+SOLI;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": RecUrl
        });
        urlEvent.fire();*/
    },
    
    /*Configure : function(cmp, event, helper) { 
        var versionId = event.currentTarget.getAttribute('data-versionId');       
        var URL = '/apex/ERP7__ProductConfiguratorLC?RId='+versionId;
        window.open(URL,'_blank');
    },*/
    
    //===============Product Configuration start===================
    Configure : function(cmp, event, helper) {
        var customerId=cmp.get("v.Customer.Id");
        var proforConfig=event.currentTarget.getAttribute('data-proId');
        cmp.set("v.proforConfig",proforConfig);
        var action = cmp.get("c.getOptionProd");
        action.setParams({proforConfig : proforConfig,customer : customerId});
        action.setCallback(this, function(response){
            var state=response.getState();	
            if(state==="SUCCESS"){
              
                cmp.set("v.proOptions",response.getReturnValue().featrWrapper);
              
                cmp.set("v.totalStock",response.getReturnValue().totalStock);
               
                cmp.set("v.proName",response.getReturnValue().product.Name);
                cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                helper.optionRules(cmp,event,proforConfig);
                $A.util.addClass(cmp.find("configModal1"), 'slds-fade-in-open');
                $A.util.addClass(cmp.find("configModalBackdrop"), 'slds-fade-in-open');
            }
        });
        $A.enqueueAction(action);        
    },
    
    confirmConfiguration : function(cmp,event,helper){
       
        cmp.set("v.exceptionError",'');
        cmp.set("v.selConfiguration",[]);
        var proFeatureMap=cmp.get("v.proFeatureMap");
        var theMap = cmp.get("v.proMap");
        var selectedProds=[];
        var selProTotalPri=0;
        var selConfiguration=cmp.get("v.selConfiguration");
        var proOptions=cmp.get("v.proOptions");
       
        for(var i=0; i<proOptions.length;i++){
            var feature=proOptions[i].feature.Name;
            var count=0;
            for(var j=0;j<proOptions[i].featOpt.length;j++){
                
                var opt=proOptions[i].featOpt[j].Id;
                if(document.getElementById(opt).checked){
                    var totalStock=cmp.get('v.totalStock');
                    for(var l=0;l<totalStock.length;l++){
                        if(totalStock[l].ProId == proOptions[i].featOpt[j].ERP7__Optional_SKU__r.Id){
                           
                            if(totalStock[l].stockAvlb > 0 || proOptions[i].featOpt[j].ERP7__Optional_SKU__r.ERP7__Allow_Back_Orders__c){
                                
                                var opt1=proOptions[i].featOpt[j].ERP7__Optional_SKU__r.Id;
                                selConfiguration.push(proOptions[i].featOpt[j].ERP7__Optional_SKU__r.Name);
                                selectedProds.push(opt1);
                                //theMap[opt1]=proOptions[i].quantity;;
                                proFeatureMap[opt1]=proOptions[i].feature.Id;
                                for(var k=0;k<proOptions[i].pbe.length;k++){
                                    /*if(proOptions[i].featOpt[j].ERP7__Optional_SKU__r.Id==proOptions[i].pbe[k].Product2Id){
                                        
                                        var quantity1=proOptions[i].quantity;
                                        
                                        selProTotalPri+=parseFloat(proOptions[i].pbe[k].UnitPrice)*parseFloat(quantity1);
                                    }*/
                                    if(proOptions[i].featOpt[j].ERP7__Optional_SKU__r.Id==proOptions[i].pbe[k].Product2Id){
                                        
                                        var quantity1=document.getElementsByName(proOptions[i].pbe[k].Product2Id)[0].value;                                        
                                        
                                        selProTotalPri+=parseFloat(proOptions[i].pbe[k].UnitPrice)*parseFloat(quantity1);
                                    }
                                }
                               
                                count=1;
                                break;
                            }
                            else{
                                cmp.set("v.exceptionError",'Insufficient stock for '+proOptions[i].featOpt[j].ERP7__Optional_SKU__r.Name);
                                return;
                            }
                        }
                    }
                    /*var opt1=proOptions[i].featOpt[j].ERP7__Optional_SKU__r.Id;
                    selectedProds.push(opt1);
                    count=1;
                    break;*/
                }
            }            
            if(count == 0){
                //alert('Please select '+feature);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Warning',
                    'type': 'warning',
                    'mode': 'dismissable',
                    'message': 'Please select '+feature
                });
                toastEvent.fire();
                
                return;
            }
        }   
        
        var prodId=cmp.get("v.proforConfig");
        var theMap = cmp.get("v.proMap");
        for(var i=0;i<selectedProds.length;i++){
            
            var qunaity=document.getElementsByName(selectedProds[i])[0].value;
           
             theMap[selectedProds[i]]=qunaity;
        }
        
        cmp.set("v.proMap",theMap);
        
        var action=cmp.get("c.createVersion");
        action.setParams({
            "selectedProds" : JSON.stringify(cmp.get("v.proMap")),
            //proOptions : JSON.stringify(proOptions),
            proFeatureMap : JSON.stringify(cmp.get("v.proFeatureMap")),
            prodId : prodId
        });
        action.setCallback(this, function(response){
            var state=response.getState();	
            if(state === "SUCCESS"){
               
                cmp.set("v.proMap",{});
                var obj=cmp.get("v.ProductsAndDiscountsWrapperListt");
                
                var objForConfigure=[];
                for(var i=0;i<obj.length;i++){   
                    
                    if(prodId == obj[i].product.Id){
                        
                        obj[i].Version=response.getReturnValue();
                        obj[i].pricebookEntry.UnitPrice+=selProTotalPri;
                        
                        objForConfigure=obj[i];
                        break;
                    }
                }
                cmp.set("v.ProductsAndDiscountsWrapperListt",obj);
               
                helper.VersionChanged(cmp,event,objForConfigure,prodId);
              
                $A.util.removeClass(cmp.find("configModal1"), 'slds-fade-in-open');
                $A.util.removeClass(cmp.find("configModalBackdrop"), 'slds-fade-in-open');
                //var sObjectUrl='https://'+window.location.hostname.split('--')[0]+'.lightning.force.com/lightning/r/ERP7__Version__c/'+response.getReturnValue()+'/view';
                //window.open(sObjectUrl,'_parent');
            }
        });
        $A.enqueueAction(action);
    },
    
    closeConfigureModal : function(cmp, event){
        $A.util.removeClass(cmp.find("configModal1"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("configModalBackdrop"), 'slds-fade-in-open');
    },
    
    detailPage : function(cmp,event,helper){
        var RecId = event.currentTarget.getAttribute('data-proId');
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    handleChange : function(cmp,event,helper){
        
        var currentTarget=event.currentTarget.dataset.value;
        //var currentTarget=event.currentTarget.getAttribute('id');
        var feature = event.currentTarget.getAttribute('data-feature');
       
        helper.disableOthers(cmp,event,currentTarget,feature);
    },
    //================Product configuration end==================================
    
    tab1 : function(component, event, helper) {
        component.set("v.salesOrderTab",true);
        component.set("v.paymentTab",false);
        component.set("v.deliveryTab",false);
        component.set("v.chatterTab",false);
        component.set("v.accountTab",false);
    },
    
    tab2 : function(component, event, helper) {
        component.set("v.salesOrderTab",false);
        component.set("v.paymentTab",true);
        component.set("v.deliveryTab",false);
        component.set("v.chatterTab",false);
        component.set("v.accountTab",false);
    },
    
    tab3 : function(component, event, helper) {
        component.set("v.salesOrderTab",false);
        component.set("v.paymentTab",false);
        component.set("v.deliveryTab",true);
        component.set("v.chatterTab",false);
        component.set("v.accountTab",false);
    },
    
    tab4 : function(component, event, helper) {
        component.set("v.salesOrderTab",false);
        component.set("v.paymentTab",false);
        component.set("v.deliveryTab",false);
        component.set("v.chatterTab",true);
        component.set("v.accountTab",false);
    },
    
    tab5 : function(component, event, helper) {
        component.set("v.salesOrderTab",false);
        component.set("v.paymentTab",false);
        component.set("v.deliveryTab",false);
        component.set("v.chatterTab",false);
        component.set("v.accountTab",true);
    },
    
    openCardModal : function(cmp, event, helper) {
       
        /*
        cmp.set('v.selInvList',[]);
        var action=cmp.get('c.SOInvoiceList');
        action.setParams({
            SOId:cmp.get("v.SalesOrder.Id")
        });
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS"){
               
                var res=response.getReturnValue();
                cmp.set('v.allInvoices',res);
                var invList=[];
                for(var i in res){
                    var inv = {
                        "label": res[i].Name,
                        "value": res[i].Id
                    };
                    invList.push(inv);
                }
                cmp.set('v.invList',invList);
                
                $A.util.addClass(cmp.find("myModalCard"),"slds-fade-in-open");
                $A.util.addClass(cmp.find("myModalCardBackdrop"),"slds-backdrop_open");
            }else{
                console.log('Error:',response.getError());
            }
        });
        $A.enqueueAction(action);*/
        
        $A.util.addClass(cmp.find("myModalCard"),"slds-fade-in-open");
        $A.util.addClass(cmp.find("myModalCardBackdrop"),"slds-backdrop_open");
    },
    
    closeCardModal : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalCard"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalCardBackdrop"),"slds-backdrop_open");
        component.popInit();
    },
    
    /*afterSelectInv : function(cmp,event,helper){
       
        
        var selectedInv = event.getParam("value");
        
        var allInvoices=cmp.get('v.allInvoices');
        var totalAmt=0;
        for(var i in selectedInv){
            for(var j in allInvoices){
                if(selectedInv[i] == allInvoices[j].Id){
                    totalAmt+=allInvoices[j].ERP7__Total_Due__c;
                }
            }
        }
        cmp.set('v.Payment.ERP7__Total_Amount__c',totalAmt);
    },*/
    
    openBankModal : function(component, event, helper) {
        $A.util.addClass(component.find("myModalBank"),"slds-fade-in-open");
        $A.util.addClass(component.find("myModalBankBackdrop"),"slds-backdrop_open");
    },
    
    closeBankModal : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalBank"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalBankBackdrop"),"slds-backdrop_open");
        component.popInit();
    },
    
    openCashModal : function(component, event, helper) {
        $A.util.addClass(component.find("myModalCash"),"slds-fade-in-open");
        $A.util.addClass(component.find("myModalCashBackdrop"),"slds-backdrop_open");
    },
    
    closeCashModal : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalCash"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalCashBackdrop"),"slds-backdrop_open");
        component.popInit();
    },
    
    openAccountModal : function(component, event, helper) {
        $A.util.addClass(component.find("myModalAcc"),"slds-fade-in-open");
        $A.util.addClass(component.find("myModalAccBackdrop"),"slds-backdrop_open");
    },
    
    closeAccountModal : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalAcc"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalAccBackdrop"),"slds-backdrop_open");
        component.popInit();
    },
    
    openContactModal : function(component, event, helper) {
        $A.util.addClass(component.find("myModalCon"),"slds-fade-in-open");
        $A.util.addClass(component.find("myModalConBackdrop"),"slds-backdrop_open");
    },
    
    closeContactModal : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalCon"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalConBackdrop"),"slds-backdrop_open");
        component.popInit();
    },
    
    openAddressModal : function(component, event, helper) {
        $A.util.addClass(component.find("myModalAdr"),"slds-fade-in-open");
        $A.util.addClass(component.find("myModalAdrBackdrop"),"slds-backdrop_open");
    },
    
    closeAddressModal : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalAdr"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalAdrBackdrop"),"slds-backdrop_open");
    },
    
    openUPSModal : function(component, event, helper) {
        $A.util.addClass(component.find("myModalUPS"),"slds-fade-in-open");
        $A.util.addClass(component.find("myModalUPSBackdrop"),"slds-backdrop_open");
    },
    
    closeUPSModal : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalUPS"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalUPSBackdrop"),"slds-backdrop_open");
        component.popInit();
    },
    
    openFedExModal : function(component, event, helper) {
        $A.util.addClass(component.find("myModalFedEx"),"slds-fade-in-open");
        $A.util.addClass(component.find("myModalFedExBackdrop"),"slds-backdrop_open");
    },
    
    closeFedExModal : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalFedEx"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalFedExBackdrop"),"slds-backdrop_open");
        component.popInit();
    },
    
    openShipmentModal : function(component, event, helper) {
        $A.util.addClass(component.find("myModalSOShipment"),"slds-fade-in-open");
        $A.util.addClass(component.find("myModalSOShipmentBackdrop"),"slds-backdrop_open");
    },
    
    closeShipmentModal : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalSOShipment"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalSOShipmentBackdrop"),"slds-backdrop_open");
        component.popInit();
    },
    
    openDHLModal : function(component, event, helper) {
        $A.util.addClass(component.find("myModalDHL"),"slds-fade-in-open");
        $A.util.addClass(component.find("myModalDHLBackdrop"),"slds-backdrop_open");
    },
    
    closeDHLModal : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalDHL"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalDHLBackdrop"),"slds-backdrop_open");
        component.popInit();
    },
    
    openApplyCredModal : function(component, event, helper) {
        $A.util.addClass(component.find("myModalApplyCred"),"slds-fade-in-open");
        $A.util.addClass(component.find("myModalApplyBackdrop"),"slds-backdrop_open");
    },
    
    closeApplyCredModal : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalApplyCred"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalApplyBackdrop"),"slds-backdrop_open");
        component.popInit();
    },
    
    openMyModalLoyalty : function(component, event, helper) {
        $A.util.addClass(component.find("myModalLoyalty"),"slds-fade-in-open");
        $A.util.addClass(component.find("myModalLoyaltyBackdrop"),"slds-backdrop_open");
    },
    
    closeMyModalLoyalty : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalLoyalty"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalLoyaltyBackdrop"),"slds-backdrop_open");
        component.set("v.LoyaltyError","");
        component.set("v.LoyaltyPoint2Use","");
        component.popInit();
    },
    
    closeCurrentBatchSerial : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalcurrentBatchSerial"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalcurrentBatchSerialBackdrop"),"slds-backdrop_open");
    },
    
    closeError : function (component, event, helper){
        component.set("v.exceptionError", "");
    }
    //            <div class="slds-backdrop" aura:id="myModalCardBackdrop"></div>
})