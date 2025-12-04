({
    doInit : function(component, event, helper){
       // helper.showToast('error','Error!','testing');
        if(component.get("v.DNId")!=null || component.get("v.DNId")!= undefined || component.get("v.DNId")!=''){
            component.set("v.payment.ERP7__Debit_Note__c", component.get("v.DNId"));
        }
    },
    
    fetchDNDetails : function(component, event, helper){
        var action = component.get("c.fetchDebitNoteDetails");
        action.setParams({"DId":component.get("v.payment.ERP7__Debit_Note__c")});
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.payment.ERP7__Purchase_Orders__c", result.ERP7__Purchase_Orders__c);
                component.set("v.payment.ERP7__Bill__c", result.ERP7__Vendor_Invoice_Bill__c);
                component.set("v.payment.ERP7__Accounts__c", result.ERP7__Account__c);
                component.set("v.payment.ERP7__Account__c", result.ERP7__Organisation__c);
                component.set("v.payment.ERP7__Total_Amount__c", result.ERP7__Debit__c);
                //var now =  new Date();
                //component.set("v.payment.ERP7__Payment_Date__c", now);
            }
        });
        $A.enqueueAction(action);
    },
    
    cancel : function(component, event, helper){
        //history.back();
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Accounts_Payable",
            componentAttributes: {
                "showTabs" : 'Credit_debit_notes'
            }
        });
        evt.fire();
    },
    
    savePayment : function(c, e, h){
        var showError=false;
        if((c.get("v.payment.ERP7__Debit_Note__c") == '' || c.get("v.payment.ERP7__Debit_Note__c")==undefined || c.get("v.payment.ERP7__Debit_Note__c")==null)){
            showError = true;
            h.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_select_the_Debit_Note'));
        }
        if((c.get("v.payment.ERP7__Accounts__c")=='' || c.get("v.payment.ERP7__Accounts__c")==undefined || c.get("v.payment.ERP7__Accounts__c")==null)&& !(showError)){
            showError = true;
            h.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH1_please_select_the_vendor'));
        }
        if((c.get("v.payment.ERP7__Total_Amount__c")=='' || c.get("v.payment.ERP7__Total_Amount__c")==undefined || c.get("v.payment.ERP7__Total_Amount__c")==null)&& !(showError)){
            showError = true;
            h.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_Enter_the_Amount'));
        }
        if((c.get("v.payment.ERP7__Payment_Account__c")=='' || c.get("v.payment.ERP7__Payment_Account__c")==undefined || c.get("v.payment.ERP7__Payment_Account__c")==null)&& !(showError)){
            showError = true;
            h.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH2_please_select_the_payment_account'));
        }
        if((c.get("v.payment.ERP7__Reference_Cheque_No__c")=='' || c.get("v.payment.ERP7__Reference_Cheque_No__c")==undefined || c.get("v.payment.ERP7__Reference_Cheque_No__c")==null)&& !(showError)){
            showError = true;
            h.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH3_please_Enter_the_reference_number'));
        }
        if(!showError){
        c.set("v.showMmainSpin", true);
        var a = c.get("c.saveDebitNotePayment");
        a.setParams({payment:JSON.stringify(c.get("v.payment")),PM:c.get('v.paymentMode')
                    });
        a.setCallback(this,function(res){
            if(res.getState()==='SUCCESS'){
                var result = res.getReturnValue();
                var paymentName = res.getReturnValue().pay;
                h.showToast($A.get('$Label.c.Success'),'Success',paymentName.Name+$A.get('$Label.c.Is_Created'));
                if(!$A.util.isUndefined(result['error'])){
                    h.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',result['error']);
                    return;
                }
                if(c.get("v.navigateToRecord")){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    if(!$A.util.isUndefined(navEvt)){
                       /* navEvt.setParams({
                            "recordId": ['payments'].Id
                        });
                        navEvt.fire();*/
                        var url = '/'+c.get("v.payment.ERP7__Debit_Note__c");
                        window.open(url, "_self");
                    }else {
                        var url = '/'+c.get("v.payment.ERP7__Debit_Note__c");
                        window.open(url, "_self");
                    }
                }else{
                    /*var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:AccountsReceivable",
                        componentAttributes: {
                            "showTabs" : 'pay',
                            "setSearch" : paymentName.Name
                        }
                    });
                    evt.fire(); */
                    var url = '/'+c.get("v.payment.ERP7__Debit_Note__c");
                    window.open(url, "_self");
                }
            }else{
                c.set("v.showMmainSpin", false);
            }
        });
        $A.enqueueAction(a);
        }
    }
})