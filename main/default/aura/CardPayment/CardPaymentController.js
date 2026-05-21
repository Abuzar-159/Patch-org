({
	getAllPaymentsDetails : function(cmp, event, helper) { 
    	try{
            var CurrentSiteUrl = $Site.CurrentSiteUrl;
            
            var SiteName = $Site.Name;
            
            var SiteDomain = $Site.Domain;
            
            var CustomWebAddress = $Site.CustomWebAddress;
            
            var OriginalUrl = $Site.OriginalUrl;
            
        } catch(err) {
            console.log("Exception : "+err.message);
        } 
        
        var vson = cmp.get("v.SON");
        var invNo = cmp.get("v.IVN");
        var accId=cmp.get("v.AccountId");
        
        if(vson != undefined && vson != '' && vson != null){
           
            var action = cmp.get("c.getAllPayDetails2");
            action.setParams({sony:vson,accf:"",conf:""});
            action.setCallback(this, function(response) {
                var state = response.getState();
              
                if (state === "SUCCESS") {
                    console.log('resposne of getAllPayDetails:',response.getReturnValue());
                    cmp.set("v.logo", response.getReturnValue().logo);
                    var logo=$A.get("$Label.c.Org_Logo");
                    cmp.set("v.logo",logo);
                    cmp.set("v.SalesOrder", response.getReturnValue().Order);
                    var inv = response.getReturnValue().invoice;
                    cmp.set("v.Invoice", response.getReturnValue().invoice);
                    var BAlength = response.getReturnValue().billingAddresses.length;
                    //alert(BAlength);
                    cmp.set("v.BillingAddress", response.getReturnValue().billingAddresses[0]);
                    if(BAlength > 0){
                        cmp.set("v.County", response.getReturnValue().billingAddresses[0].ERP7__State__c);
                      	cmp.set("v.Country", response.getReturnValue().billingAddresses[0].ERP7__Country__c);
                    }
                    cmp.set("v.Payment", response.getReturnValue().Payment);
                    cmp.set("v.PaymentMethod", response.getReturnValue().PaymentMethod);
                    cmp.set("v.Payment.ERP7__Total_Amount__c", response.getReturnValue().Order.ERP7__Due_Amount__c);
                    cmp.set("v.Payment.ERP7__First_Name__c", response.getReturnValue().Contact.FirstName);
                    cmp.set("v.Payment.ERP7__Last_Name__c", response.getReturnValue().Contact.LastName);
                    cmp.set("v.PaymentMethod.ERP7__Name_on_Card__c", response.getReturnValue().Customer.Name);
                    cmp.set("v.finalDue", response.getReturnValue().Order.ERP7__Due_Amount__c);
                    cmp.set("v.PaymentMethod.ERP7__CardType__c", '');
                    cmp.set("v.PaymentMethod.ERP7__Card_Number__c", '');
                    cmp.set("v.CVV", '');
                    cmp.set("v.PaymentMethod.ERP7__Card_Expiration_Month__c", '');
                    cmp.set("v.PaymentMethod.ERP7__Card_Expiration_Year__c", '');
                    cmp.set("v.CardError", '');
                    
                    //cmp.find("cardType").set("v.options", response.getReturnValue().CardTypes);
                    cmp.set("v.cardTypeOptions",response.getReturnValue().CardTypes);
                    //cmp.find("expiryMonth").set("v.options", response.getReturnValue().ExpiryMonth);
                    cmp.set("v.expiryMonthOptions",response.getReturnValue().ExpiryMonth);
                    
                    //cmp.find("expiryYear").set("v.options", response.getReturnValue().ExpiryYear);
                    cmp.set("v.expiryYearOptions",response.getReturnValue().ExpiryYear);
                    
                    //cmp.find("CountryList").set("v.options", response.getReturnValue().CountryList);
                    cmp.set("v.CountryListOptions",response.getReturnValue().CountryList);
                    
                    //cmp.find("CountyList").set("v.options", response.getReturnValue().CountyList);
                    cmp.set("v.CountyListOptions",response.getReturnValue().CountyList);
                    
                    cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                    
                    if(cmp.get("v.AccountId")!=undefined && cmp.get("v.AccountId")!='') helper.fetchCustomerDetails(cmp, event, helper);
                    document.getElementById("cardPayment").style.visibility = "hidden";
                    helper.getMerchantUserID(cmp, event, helper);
                }
            });
            $A.enqueueAction(action);
        } else if(invNo != undefined && invNo != '' && invNo != null){
            
        	var action = cmp.get("c.getInvoicePayDetails");
            action.setParams({invId:invNo});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);  
                if (state === "SUCCESS") {
                    
                    cmp.set("v.logo", response.getReturnValue().logo);
                    cmp.set("v.Invoice", response.getReturnValue().invoice);
                    var BAlength = response.getReturnValue().billingAddresses.length;
                    cmp.set("v.BillingAddress", response.getReturnValue().billingAddresses[0]);
                    if(BAlength > 0){
                        cmp.set("v.County", response.getReturnValue().billingAddresses[0].ERP7__State__c);
                      	cmp.set("v.Country", response.getReturnValue().billingAddresses[0].ERP7__Country__c);
                    }
                    cmp.set("v.Payment", response.getReturnValue().Payment);
                    cmp.set("v.PaymentMethod", response.getReturnValue().PaymentMethod);
                    cmp.set("v.Payment.ERP7__Total_Amount__c", response.getReturnValue().invoice.ERP7__Total_Due__c);
                    cmp.set("v.Payment.ERP7__First_Name__c", response.getReturnValue().Contact.FirstName);
                    cmp.set("v.Payment.ERP7__Last_Name__c", response.getReturnValue().Contact.LastName);
                    cmp.set("v.Payment.ERP7__Email_Address__c", response.getReturnValue().Contact.Email);
                    cmp.set("v.Payment.ERP7__Accounts__c", response.getReturnValue().invoice.ERP7__Account__c);
                    cmp.set("v.PaymentMethod.ERP7__Name_on_Card__c", response.getReturnValue().Customer.Name);
                    cmp.set("v.finalDue", response.getReturnValue().invoice.ERP7__Total_Due__c);
                    cmp.set("v.PaymentMethod.ERP7__CardType__c", '');
                    cmp.set("v.PaymentMethod.ERP7__Card_Number__c", '');
                    cmp.set("v.PaymentMethod.ERP7__Card_Expiration_Month__c", '');
                    cmp.set("v.PaymentMethod.ERP7__Card_Expiration_Year__c", '');
                    cmp.set("v.CVV", '');
                    cmp.set("v.CardError", '');
                    cmp.find("cardType").set("v.options", response.getReturnValue().CardTypes);
                    cmp.find("expiryMonth").set("v.options", response.getReturnValue().ExpiryMonth);
                    cmp.find("expiryYear").set("v.options", response.getReturnValue().ExpiryYear);
                    cmp.find("CountryList").set("v.options", response.getReturnValue().CountryList);
                    cmp.find("CountyList").set("v.options", response.getReturnValue().CountyList);
                    cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                    
                    if(cmp.get("v.AccountId")!=undefined && cmp.get("v.AccountId")!='') helper.fetchCustomerDetails(cmp, event, helper);
                    document.getElementById("cardPayment").style.visibility = "hidden";
                    helper.getMerchantUserID(cmp, event, helper);
                }
            });
            $A.enqueueAction(action);
        }else if(accId != undefined && accId != '' && accId != null){
           
            var action = cmp.get("c.getAccountPayDetails");
            action.setParams({CUST:accId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    
                    cmp.set("v.logo", response.getReturnValue().logo);
                    //cmp.set("v.Invoice", response.getReturnValue().invoice);
                    var BAlength = response.getReturnValue().billingAddresses.length;
                    cmp.set("v.BillingAddress", response.getReturnValue().billingAddresses[0]);
                    if(BAlength > 0){
                        cmp.set("v.County", response.getReturnValue().billingAddresses[0].ERP7__State__c);
                      	cmp.set("v.Country", response.getReturnValue().billingAddresses[0].ERP7__Country__c);
                    }
                    cmp.set("v.Payment", response.getReturnValue().Payment);
                    cmp.set("v.PaymentMethod", response.getReturnValue().PaymentMethod);
                    cmp.set("v.Payment.ERP7__Total_Amount__c", cmp.get("v.DueAmount"));
                    cmp.set("v.Payment.ERP7__First_Name__c", response.getReturnValue().Contact.FirstName);
                    cmp.set("v.Payment.ERP7__Last_Name__c", response.getReturnValue().Contact.LastName);
                    cmp.set("v.Payment.ERP7__Email_Address__c", response.getReturnValue().Contact.Email);
                    cmp.set("v.Payment.ERP7__Accounts__c", cmp.get('v.AccountId'));
                    cmp.set("v.PaymentMethod.ERP7__Name_on_Card__c", response.getReturnValue().Customer.Name);
                    cmp.set("v.finalDue", cmp.get("v.DueAmount"));
                    cmp.set("v.PaymentMethod.ERP7__CardType__c", '');
                    cmp.set("v.PaymentMethod.ERP7__Card_Number__c", '');
                    cmp.set("v.PaymentMethod.ERP7__Card_Expiration_Month__c", '');
                    cmp.set("v.PaymentMethod.ERP7__Card_Expiration_Year__c", '');
                    cmp.set("v.CVV", '');
                    cmp.set("v.CardError", '');
                    cmp.find("cardType").set("v.options", response.getReturnValue().CardTypes);
                    cmp.find("expiryMonth").set("v.options", response.getReturnValue().ExpiryMonth);
                    cmp.find("expiryYear").set("v.options", response.getReturnValue().ExpiryYear);
                    cmp.find("CountryList").set("v.options", response.getReturnValue().CountryList);
                    cmp.find("CountyList").set("v.options", response.getReturnValue().CountyList);
                    cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                    
                    //if(cmp.get("v.AccountId")!=undefined && cmp.get("v.AccountId")!='') helper.fetchCustomerDetails1(cmp, event, helper);
                    document.getElementById("cardPayment").style.visibility = "hidden";
                    helper.getMerchantUserID(cmp, event, helper);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    CardPayment: function(cmp, event) {
       
        var vson = cmp.get("v.SON");
        var invNo = cmp.get("v.IVN");
        var AccId=cmp.get('v.AccountId');
       
        
        document.getElementById("cardPayment").style.visibility = "visible";
        var Customer = new Array(cmp.get("v.Customer"));
        var custsize = Customer.length;
        var SalesOrder = new Array(cmp.get("v.SalesOrder"));
        var sosize = SalesOrder.length;
        var FinalDue = cmp.get("v.finalDue");
        var CVV = cmp.get("v.CVV");
        var BillingAddress = cmp.get("v.BillingAddress");
        cmp.set("v.Payment.ERP7__Address_Line1__c", BillingAddress.ERP7__Address_Line1__c);
        cmp.set("v.Payment.ERP7__Address_Line2__c", BillingAddress.ERP7__Address_Line2__c);
        cmp.set("v.Payment.ERP7__City__c", BillingAddress.ERP7__City__c);
        cmp.set("v.Payment.ERP7__State__c", cmp.get("v.County"));
        cmp.set("v.Payment.ERP7__Country__c", cmp.get("v.Country"));
        cmp.set("v.Payment.ERP7__Zipcode__c", BillingAddress.ERP7__Postal_Code__c);
        
        var Invoice = cmp.get("v.Invoice");
       
        if(Invoice != undefined && Invoice.Id != undefined) cmp.set("v.Payment.ERP7__Invoice__c", Invoice.Id);
        
        var Payments = JSON.stringify(cmp.get("v.Payment"));
        var PaymentMethods = JSON.stringify(cmp.get("v.PaymentMethod"));
        var PaymentMethod = new Array(cmp.get("v.PaymentMethod"));
        var Payment = new Array(cmp.get("v.Payment"));
        var paymentsize = Payment.length;
        var Proceed = false;
        if(vson != undefined && vson != '' && vson != null) var RecId = SalesOrder[0].Id;
        
        if(vson != undefined && vson != '' && vson != null && PaymentMethod[0].ERP7__Name_on_Card__c != undefined && PaymentMethod[0].ERP7__CardType__c != undefined && PaymentMethod[0].ERP7__Card_Number__c != undefined && PaymentMethod[0].ERP7__Card_Expiration_Month__c != undefined && PaymentMethod[0].ERP7__Card_Expiration_Year__c != undefined && SalesOrder != null && SalesOrder[0].Id != undefined && Customer.length > 0 && SalesOrder.length > 0 && Payment.length > 0 && FinalDue > 0 && Payment[0].ERP7__Total_Amount__c > 0 && Payment[0].ERP7__Total_Amount__c <= FinalDue &&
            Payment[0].ERP7__First_Name__c != undefined && Payment[0].ERP7__Last_Name__c != undefined && Payment[0].ERP7__Address_Line1__c != undefined && Payment[0].ERP7__City__c != undefined && Payment[0].ERP7__Zipcode__c != undefined){
         	Proceed = true;
            cmp.set("v.CardError", '');
        } else if(PaymentMethod[0].ERP7__Name_on_Card__c != undefined && PaymentMethod[0].ERP7__CardType__c != undefined && PaymentMethod[0].ERP7__Card_Number__c != undefined && PaymentMethod[0].ERP7__Card_Expiration_Month__c != undefined && PaymentMethod[0].ERP7__Card_Expiration_Year__c != undefined && invNo != '' && Customer.length > 0 && Payment.length > 0 && FinalDue > 0 && 
                  Payment[0].ERP7__Total_Amount__c > 0 && Payment[0].ERP7__Total_Amount__c <= FinalDue && Payment[0].ERP7__First_Name__c != undefined && Payment[0].ERP7__Last_Name__c != undefined && Payment[0].ERP7__Address_Line1__c != undefined && Payment[0].ERP7__City__c != undefined && Payment[0].ERP7__Zipcode__c != undefined){
         	
            Proceed = true;
            cmp.set("v.CardError", '');
        } else if(PaymentMethod[0].ERP7__Name_on_Card__c != undefined && PaymentMethod[0].ERP7__CardType__c != undefined && PaymentMethod[0].ERP7__Card_Number__c != undefined && PaymentMethod[0].ERP7__Card_Expiration_Month__c != undefined && PaymentMethod[0].ERP7__Card_Expiration_Year__c != undefined && AccId != '' && Customer.length > 0 && Payment.length > 0 && FinalDue > 0 && 
                  Payment[0].ERP7__Total_Amount__c > 0 && Payment[0].ERP7__Total_Amount__c <= FinalDue && Payment[0].ERP7__First_Name__c != undefined && Payment[0].ERP7__Last_Name__c != undefined && Payment[0].ERP7__Address_Line1__c != undefined && Payment[0].ERP7__City__c != undefined && Payment[0].ERP7__Zipcode__c != undefined){
            
            Proceed = true;
            cmp.set("v.CardError", '');	
        }else {
            cmp.set("v.CardError", "Invalid details, please provide valid details");
            document.getElementById("cardPayment").style.visibility = "hidden";
        }
       
        if(Proceed == true){
           
            if(vson != undefined && vson != '' && vson != null){
               
                var action = cmp.get("c.CreateCardPayment");
                action.setParams({ 
                    SalesOrder2Creates: SalesOrder,
                    Payments: Payments,
                    PaymentMethods: PaymentMethods,
                    CVV: CVV
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                  
                    if (state === "SUCCESS") {
                        var retVal = response.getReturnValue();
                        
                        if(response.getReturnValue() == ''){
                            
                            /*$A.util.addClass(cmp.find('SuccessPaymentModal'), "slds-fade-in-open");
                            $A.util.addClass(cmp.find('SuccessPaymentBackdrop'), "slds-backdrop--open");
                            window.close();
                            
                            document.getElementById("cardPayment").style.visibility = "hidden";*/
                            //var RecUrl = "apex/ERP7__PaymentSuccess";
                            //window.open(RecUrl,'_self');           
                            cmp.set("v.paymentSuccess", true);
                        } else{
                            cmp.set("v.CardError", response.getReturnValue()); 
                            document.getElementById("cardPayment").style.visibility = "hidden";
                        }
                    }
                });
                $A.enqueueAction(action);
            } else if(invNo != undefined && invNo != '' && invNo != null){
               
                var action = cmp.get("c.CreateInvoiceCardPayment");
                action.setParams({ 
                    invId: invNo,
                    Payments: Payments,
                    PaymentMethods: PaymentMethods,
                    CVV: CVV
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                   
                    if (state === "SUCCESS") {
                        var retVal = response.getReturnValue();
                        if(response.getReturnValue() == ''){
                            
                            //var RecUrl = "apex/ERP7__PaymentSuccess";
                            
                            //window.open(RecUrl,'_self');                  
                            cmp.set("v.paymentSuccess", true);
                        } else{
                            cmp.set("v.CardError", response.getReturnValue()); 
                            document.getElementById("cardPayment").style.visibility = "hidden";
                        }
                    }
                });
                $A.enqueueAction(action);
            }else if(AccId != undefined && AccId != '' && AccId != null){
                
                var action = cmp.get("c.CreateAccountCardPayment");
                action.setParams({ 
                    accId1: AccId,
                    Payments: Payments,
                    PaymentMethods: PaymentMethods,
                    CVV: CVV
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                   
                    if (state === "SUCCESS") {
                        var retVal = response.getReturnValue();
                        if(response.getReturnValue() == ''){
                           
                            //var RecUrl = "apex/ERP7__PaymentSuccess";
                            
                            //window.open(RecUrl,'_self');                  
                            cmp.set("v.paymentSuccess", true);
                        } else{
                            cmp.set("v.CardError", response.getReturnValue()); 
                            document.getElementById("cardPayment").style.visibility = "hidden";
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        } 
    },
    
    winClose : function(component, event, helper){          
       
        window.setTimeout(
      		$A.getCallback(function() {
                window.close();
            }), 10
		);
    },
    
    getPanel : function(component, event, helper) {
		if(component.find("cardType") != undefined) 
        var options = component.find("cardType").get("v.options");
        if(component.find("expiryYear") != undefined) 
        var options = component.find("expiryYear").get("v.options");
        if(component.find("expiryMonth") != undefined) 
        var options = component.find("expiryMonth").get("v.options");
        
        var eve=event.target.dataset.record;
         
       	if(eve=='cdc') {
        	component.set("v.displaySelect",true);
           	component.find("com2").getElement().checked=false;
           	component.find("com1").getElement().checked=true;
       	}
       	else {
        	component.set("v.displaySelect",false);
        	component.find("com1").getElement().checked=false;
        	component.find("com2").getElement().checked=true;
       	}
        helper.getMerchantUserID(component, event, helper);
	}
})