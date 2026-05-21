({
    PoDOInit: function(component, event, helper) {
        
        var action = component.get("c.populateRMAPO");
        action.setParams({
            POIds:component.get("v.poIdsList")
        });
        action.setCallback(this, function(a) {
                
        });
        $A.enqueueAction(action);
    },
    
    /*OrdItmsDOInit : function(component,event){
        console.log('inside OrdItmsDOInit');
        component.set("v.showSpinner",true);
        var SelectedPosList=component.get('v.SelectedPos');
        
        var action=component.get('c.populateOrderItems');
        action.setParams({
            "poIds":SelectedPosList
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var poliList = [];
                console.log('Response-->'+JSON.stringify(response.getReturnValue()));
                poliList = response.getReturnValue();
                component.set("v.poli",poliList);
                component.set("v.showSpinner",false);
            }else{
                var error1=response.getError();
                component.set('v.exceptionError',error1[0].message);
            }
        });
        $A.enqueueAction(action);
    },*/
    OrdItmsDOInit : function(component,event){
        console.log('inside OrdItmsDOInit');
        component.set("v.showSpinner",true);
        var SelectedPosList=component.get('v.SelectedPos');
        
        var action=component.get('c.populateOrderItems');
        action.setParams({
            "poIds":SelectedPosList
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var poliList = [];
                console.log('Response Anew-->'+JSON.stringify(response.getReturnValue()));
                poliList = response.getReturnValue();
                var overallSubtotal = 0;   // sum of base price - discount
                var overallTax = 0;        // sum of VAT
                var overallTotal = 0; 
                if (poliList && poliList.length > 0) {
                    poliList.forEach(function(poli) {
                        var basePrice = poli.Quantity * poli.UnitPrice;
                        
                        // discount in percentage
                        var discount = (poli.ERP7__Discount_Percent__c ? poli.ERP7__Discount_Percent__c : 0);
                        var discountAmount =0;// (basePrice * discount) / 100;
                        
                        // tax (assuming VAT_Amount__c is already absolute value, not %)
                        var vatAmount = (poli.ERP7__VAT_Amount__c ? poli.ERP7__VAT_Amount__c : 0);
                        poli.TaxRate=discount;
                        poli.ERP7__Discount_Percent__c=0;
                        // final total
                        poli.ERP7__Total_Price__c = basePrice - discountAmount + vatAmount;
                        overallSubtotal += basePrice;
                        overallTax += vatAmount;
                        overallTotal += poli.ERP7__Total_Price__c;
                    });
                }
                console.log('Response-->' + JSON.stringify(poliList));
                component.set("v.poli",poliList);
                console.log('poli after set 2:',component.get("v.poli"));
                component.set("v.SubTotal",overallSubtotal);
                component.set("v.TotalTax",overallTax);
                component.set("v.TotalAmount",overallTotal);
                component.set("v.Order.ERP7__Amount__c",overallTotal);
                component.set("v.showSpinner",false);
            }else{
                var error1=response.getError();
                component.set('v.exceptionError',error1[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchAddressDetails : function(component, event, helper) {
        
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
        }else{
            sforce.one.showToast({
                "title": title,
                "message": message,
                "type": type
            });
        }
        
    },
    
    fetchEmployeeRequester : function(component, event, helper){
        var action = component.get('c.fetchEmployeeRequester');
        action.setParams({});
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var res = response.getReturnValue();
                if(res != null){
                    component.set("v.Order.ERP7__Employee__c",res.Id);
                }
                
                
            }else{
                console.log('Error fetchEmployeeRequester:',response.getError());
                component.set("v.exceptionError",response.getError());
            }
        });
        $A.enqueueAction(action); 
    },
    
})