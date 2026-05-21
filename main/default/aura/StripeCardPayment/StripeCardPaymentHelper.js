({
	getMerchantUserID: function(component, event, helper) {
        var action = component.get("c.getMerchantId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var kk = response.getReturnValue().ERP7__Account_Id__c;
                component.set("v.businessId", response.getReturnValue().ERP7__Account_Id__c);
              
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchCustomerDetails: function(component, event, helper) {        
        var action = component.get("c.getCustomerDetails"); 
        action.setParams({
            "AccountId":component.get("v.AccountId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                
              	if(response.getReturnValue()!=null && response.getReturnValue()!=undefined){
                	var str=response.getReturnValue().Name;                                                          
                	var NameA = str.split(" ");
                  	if(NameA.length>1) {
                  		component.set("v.Payment.ERP7__First_Name__c",NameA[0]);   component.set("v.Payment.ERP7__Last_Name__c",NameA[1]);  
                	}else{
                    	component.set("v.Payment.ERP7__First_Name__c",NameA[0]);   component.set("v.Payment.ERP7__Last_Name__c",' '); 
                	}
                	component.set("v.SalesOrder.ERP7__Customer_Email__c",response.getReturnValue().ERP7__Email__c);
                	component.set("v.BillingAddress.ERP7__Address_Line1__c",response.getReturnValue().BillingStreet);
                	component.set("v.BillingAddress.ERP7__City__c",response.getReturnValue().BillingCity);
                	component.set("v.BillingAddress.ERP7__Postal_Code__c",response.getReturnValue().BillingPostalCode);
                	component.set("v.Payment.ERP7__Total_Amount__c",component.get("v.DueAmount"));
                    //component.set("v.County",response.getReturnValue().BillingState);
              	}                                         
            }
        });
        $A.enqueueAction(action);
    },
    
})