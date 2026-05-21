({
    doInit : function(component, event, helper) {
        var vBillDate = new Date();
        vBillDate.setDate(vBillDate.getDate());
        component.set("v.Order.EffectiveDate", vBillDate.getFullYear() + "-" + (vBillDate.getMonth() + 1) + "-" + vBillDate.getDate());
        let productsToAdd = [];
        let poliadd = {};
        poliadd.Quantity = 0;
        poliadd.UnitPrice = 0;
        poliadd.ERP7__Discount_Percent__c = 0;
        poliadd.ERP7__VAT_Amount__c = 0;
        poliadd.ERP7__Total_Price__c = 0;
        poliadd.ERP7__Detailed_Description__c = '';
        productsToAdd.push(poliadd);
        component.set("v.poli", productsToAdd);
        let poStatus = component.get("c.getStatus");
        poStatus.setCallback(this,function(response){
            let resList = response.getReturnValue();
            component.set("v.OrderStatusoptions",resList);
            //$A.util.addClass(component.find('mainSpin'), "slds-hide");//2   
            component.set("v.showSpinner",false);//uncomment         
        });
        $A.enqueueAction(poStatus);
        if(!$A.util.isUndefined(component.get("v.SelectedPos")) && !$A.util.isEmpty(component.get("v.SelectedPos")) && component.get("v.SelectedPos")!=''){
            helper.OrdItmsDOInit(component, event, helper);
        }
        helper.fetchEmployeeRequester(component, event);
        if(!$A.util.isUndefined(component.get("v.orgId")) && !$A.util.isEmpty(component.get("v.orgId")) && component.get("v.orgId")!=''){
            component.set("v.Order.ERP7__Organisation__c",component.get("v.orgId"));
        }
        if(!$A.util.isUndefined(component.get("v.vendorId")) && !$A.util.isEmpty(component.get("v.vendorId")) && component.get("v.vendorId")!=''){
            component.set("v.Order.AccountId",component.get("v.vendorId"));
        }
         component.set("v.Order.Status", 'Draft');
    },
    
    UpdateOA: function(component,event,helper){
        console.log('UpdateOA called');
        var order = component.get("v.Order");
        if(component.get("v.Order.ERP7__Organisation__c") != null && component.get("v.Order.ERP7__Organisation__c") != undefined){
            console.log('calling fetchAddressDetails from UpdateOA');
            helper.fetchAddressDetails(component,event,helper); 
        }
    },
    
    AddProducts : function(component,event,helper){
        let productsToAdd = [];
        let poliadd = {};
        productsToAdd = component.get("v.poli");
        poliadd.Quantity = 0;
        poliadd.UnitPrice = 0;
        poliadd.ERP7__Discount_Percent__c = 0;
        poliadd.ERP7__VAT_Amount__c = 0;
        poliadd.ERP7__Total_Price__c = 0;
        poliadd.ERP7__Detailed_Description__c = '';
        productsToAdd.push(poliadd);
        component.set("v.poli", productsToAdd);
    },
    
    updateTotalPrice: function(c, e, h){
        console.log('arshad inside updateTotalPrice');
        
        var items=c.get('v.poli');
        console.log('arshad inside updateTotalPrice : ',items);
        if($A.util.isUndefined(items.length)){
            var amt = items.Quantity * items.UnitPrice;
            if(amt>=0) c.set("v.Order.ERP7__Amount__c",amt.toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
        }
        else{
            var amt=0;
            var subTotal=0;
            var taxAmount=0;
            //for(var x in items){
            for(var x = 0; x < items.length; x++){
                if($A.util.isEmpty(items[x].UnitPrice) || $A.util.isUndefinedOrNull(items[x].UnitPrice)) items[x].UnitPrice=0;
                if($A.util.isEmpty(items[x].ERP7__VAT_Amount__c) || $A.util.isUndefinedOrNull(items[x].ERP7__VAT_Amount__c)) items[x].ERP7__VAT_Amount__c=0;
                if($A.util.isEmpty(items[x].Quantity) || $A.util.isUndefinedOrNull(items[x].Quantity)) items[x].Quantity=0;
                amt += ((items[x].Quantity * items[x].UnitPrice) + parseFloat(items[x].ERP7__VAT_Amount__c));
                subTotal += (items[x].Quantity * items[x].UnitPrice);
                taxAmount += parseFloat(items[x].ERP7__VAT_Amount__c);
            }
            console.log('arshad inside updateTotalPrice amt~>'+amt);
            console.log('arshad inside updateTotalPrice subTotal~>'+subTotal);
            console.log('arshad inside updateTotalPrice taxAmount~>'+taxAmount);
            if(amt >= 0) amt = amt.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
            if(subTotal >= 0) subTotal = subTotal.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
            c.set("v.TotalAmount",amt);
            c.set("v.TotalTax",taxAmount);
            c.set("v.SubTotal",subTotal);
            c.set("v.Order.ERP7__Amount__c",amt);
        }
    },
    
    fetchAccountDetails : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var action=component.get('c.fetchAccDetails');
        action.setParams({
            "customerId":component.get("v.Order.AccountId")
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                console.log('Response-->'+JSON.stringify(response.getReturnValue()));
                component.set("v.Order.ERP7__Order_Profile__c",response.getReturnValue().orderProfileId);
                component.set("v.Order.ERP7__Contact__c",response.getReturnValue().conId);
                component.set("v.Order.ERP7__Bill_To_Address__c",response.getReturnValue().billAddId);
                component.set("v.Order.ERP7__Ship_To_Address__c",response.getReturnValue().shipAddId);
                component.set("v.showSpinner",false);
            }else{
                var error1=response.getError();
                component.set('v.exceptionError',error1[0].message);
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    CreateUpdateOrder : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var ordItemList = component.get("v.poli");
        var orderobj = component.get("v.Order");
		component.NOerrors =  true;
        if(component.NOerrors){
            var showError=false;
            
            if((component.get("v.Order.ERP7__Channel__c")==undefined || component.get("v.Order.ERP7__Channel__c")==null)){
                showError = true;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Please select the Channel');
            }
            if((component.get("v.Order.ERP7__Order_Profile__c")==undefined || component.get("v.Order.ERP7__Order_Profile__c")==null || component.get("v.Order.ERP7__Order_Profile__c")=='')){
                showError = true;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Please select the Order Profile');
            }
            if((component.get("v.Order.EffectiveDate")=='' || component.get("v.Order.EffectiveDate")==undefined || component.get("v.Order.EffectiveDate")==null)&& !(showError)){
                showError = true;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Please select the Expected Date');
            }
            if((component.get("v.Order.ERP7__Employee__c")=='' || component.get("v.Order.ERP7__Employee__c")==undefined || component.get("v.Order.ERP7__Employee__c")==null)&& !(showError)){
                showError = true;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Please select the Employee Requester');
            }
            if((component.get("v.Order.AccountId")=='' || component.get("v.Order.AccountId")==undefined || component.get("v.Order.AccountId")==null)&& !(showError)){
                showError = true;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Please select the Customer');
            }
            if((component.get("v.Order.ERP7__Contact__c")=='' || component.get("v.Order.ERP7__Contact__c")==undefined || component.get("v.Order.ERP7__Contact__c")==null)&& !(showError)){
                showError = true;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Please select the Contact');
            }
            if((component.get("v.Order.ERP7__Bill_To_Address__c")=='' || component.get("v.Order.ERP7__Bill_To_Address__c")==undefined || component.get("v.Order.ERP7__Bill_To_Address__c")==null)&& !(showError)){
                showError = true;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Please select the Billing Address');
            }
            if((component.get("v.Order.ERP7__Ship_To_Address__c")=='' || component.get("v.Order.ERP7__Ship_To_Address__c")==undefined || component.get("v.Order.ERP7__Ship_To_Address__c")==null)&& !(showError)){
                showError = true;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Please select the Shipping Address');
            }
            if((component.get("v.Order.ERP7__Organisation__c")=='' || component.get("v.Order.ERP7__Organisation__c")==undefined || component.get("v.Order.ERP7__Organisation__c")==null)&& !(showError)){
                showError = true;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Please select the Organisation');
            }
            component.set("v.showSpinner", false);
            if(ordItemList.length>0 && !(showError)){
                component.set("v.showSpinner",true);
                var saveAction = component.get("c.createOrder");
                let jsonOrder  = JSON.stringify(orderobj);
                let jsonOrderItems = JSON.stringify(ordItemList);
                var RTName;
                saveAction.setParams({"Order": jsonOrder, "ordItems" :jsonOrderItems});
                saveAction.setCallback(this,function(response){
                    if(response.getState() === 'SUCCESS'){ 
                        try{
                            
                            var result = response.getReturnValue();
                            if(!$A.util.isUndefinedOrNull(result['error'])) {
                                helper.showToast('Error!','error',result['error']);
                                component.set("v.showSpinner",false);
                                return ;
                            }
                            //if(component.get("v.isUpdate")) helper.showToast($A.get('$Label.c.Success'),'success', $A.get('$Label.c.PH_CredNotes_Credit_Note_Updated_Successfully'));
                            //else 
                            helper.showToast($A.get('$Label.c.Success'),'success', 'Order Created Successfully');
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef : "c:InterCompanyInvoicing",
                                componentAttributes: {
                                }
                            });
                            evt.fire();
                            component.set("v.showSpinner",false);
                        }catch(e){
                            component.set("v.showSpinner",false);
                            console.log('exception in trycatch~>'+e);
                        }
                    }else{
                        component.set("v.showSpinner",false);
                        var errors = response.getError();
                        console.log("server error : ", errors);
                        helper.showToast('Error!','error',errors[0].message);
                    }
                });
                $A.enqueueAction(saveAction);
            }else{
                if(!showError)helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Please_add_a_Line_Item'));
            } 
        }else{
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Review_All_Errors'));
            component.set("v.showSpinner", false);
        }
    },
    
    gobacktoshipment : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:InterCompanyInvoicing",
            componentAttributes: {
            }
        });
        evt.fire();
    },
    
    deletePoli :function(component, event, helper) {
        console.log('inside deletePoli');
        var poliList =[]; 
        poliList=component.get("v.poli");
        console.log('poliList before~>',JSON.stringify(poliList));
        var index=event.getParam("Index"); //component.get("v.Index2del");
        poliList.splice(index,1);        
        console.log('poliList after~>',JSON.stringify(poliList));
        component.set("v.poli",poliList);
        console.log('v.poli after~>',JSON.stringify(component.get("v.poli")));
        /*
        var items=component.get('v.poli');
        var amt=0;
        var itemToDel=component.get('v.itemToDel');
        itemToDel.push(event.getParam("itemToDelCurr"));
        console.log('itemToDelCurr in PO:',event.getParam("itemToDelCurr"));
        component.set('v.itemToDel',itemToDel);
        console.log('itemToDel:',component.get('v.itemToDel'));
        */
        var a = component.get('c.updateTotalPrice');
        $A.enqueueAction(a);
        var taxtotal = component.get('c.updateTotalTax');
        $A.enqueueAction(taxtotal);
        
    },
    
})