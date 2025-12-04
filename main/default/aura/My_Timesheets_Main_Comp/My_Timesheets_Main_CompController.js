({
    doInit: function(c, e, h) {
        c.set("v.showSpinner",true);
        var now =  new Date();
        c.set('v.today',now.getFullYear()+'-'+(now.getMonth()+1)+'-'+now.getDate());
        var a = c.get("c.fetchRefundBill");
        a.setParam("bId",c.get("v.recordId"));
        a.setCallback(this,function(r){
            if(r.getState()==='SUCCESS'){
                
                var result = r.getReturnValue();
                c.set('v.Bill',r.getReturnValue());
                c.set("v.OrgId",r.getReturnValue().ERP7__Organisation__c);
                c.set("v.payment.ERP7__Account__c",r.getReturnValue().ERP7__Organisation__c);
                c.set('v.RT','Customer Payment');
                c.set("v.payment.ERP7__Accounts__c",result.ERP7__Vendor__c);
                c.set("v.payment.ERP7__Payment_Date__c", c.get('v.today'));
                c.set("v.dueAmount",r.getReturnValue().ERP7__Amount__c);
                c.set("v.showSpinner",false);
            }else{
                c.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(a);
    },
    
    cancel : function(c, e, h){
        history.back();
    },
    
    save : function(c, e, h){
        c.set("v.showSpinner",true);
        var msg = 'Fields marked as * are required';
        c.set("v.payment.ERP7__Posted_Date__c",null);
        c.set("v.payment.ERP7__Posted__c",false);
        c.set("v.payment.ERP7__Refund_Amount__c",c.get("v.payment.ERP7__Total_Amount__c"));
        c.set("v.payment.ERP7__Refund__c",true);
        c.set("v.payment.ERP7__Bill__c",c.get("v.Bill.Id"));
        if(!$A.util.isUndefinedOrNull(c.get('v.Bill.ERP7__Purchase_Order__c'))) c.set("v.payment.ERP7__Purchase_Orders__c",c.get("v.Bill.ERP7__Purchase_Order__c"));
        
        var validation = true;
        if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Payment_Account__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Payment_Account__c'))){
            validation = false;
        }   
        if($A.util.isUndefinedOrNull(c.find("paymentAmount").get("v.value")) || $A.util.isEmpty(c.find("paymentAmount").get("v.value"))){
            c.find("paymentAmount").showHelpMessageIfInvalid();
            validation = false;
        }
        if(!$A.util.isUndefinedOrNull(c.find("checkReference")) && ($A.util.isUndefinedOrNull(c.find("checkReference").get("v.value")) || $A.util.isEmpty(c.find("checkReference").get("v.value")))){
            c.find("checkReference").showHelpMessageIfInvalid();
            validation = false;
        }
        
        if(c.get('v.payment.ERP7__Bank_Charges__c') > 0 && c.get('v.payment.ERP7__Bank_Charges__c') !='' && c.get('v.payment.ERP7__Bank_Charges__c') != undefined ){
            var total = parseInt(c.get('v.payment.ERP7__Bank_Charges__c')) + parseInt(c.get('v.payment.ERP7__Total_Amount__c'));
            if( total > c.get('v.dueAmount')){
                msg = 'Please Enter the proper amount';
                validation = false;
            }
            if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Bank_Fee_COA__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Bank_Fee_COA__c')))
            {
                validation = false;
            }
        }
        if(!validation){
            c.set("v.showSpinner",false);
            h.showToast('error','Error!', msg); 
            return;
        }
        
        var a = c.get("c.saveRefundPayment");
        a.setParams({payment:JSON.stringify(c.get("v.payment")),post:c.get('v.post'),
                     RType:c.get('v.RT'),accId : c.get("v.payment.ERP7__Accounts__c")
                    });
        a.setCallback(this,function(res){
            if(res.getState()==='SUCCESS'){
                c.set("v.showSpinner",false);
                var result = res.getReturnValue();
                var paymentName = res.getReturnValue().pay;
                c.set('v.PayName', paymentName.Name);
                h.showToast('Success','Success!',c.get('v.PayName')+' is created.');
                if(!$A.util.isUndefined(result['error'])){h.showToast('error','Error!',result['error']);return;}
                var navEvt = $A.get("e.force:navigateToSObject");
                if(!$A.util.isUndefined(navEvt)){
                    navEvt.setParams({
                        "recordId": ['payments'].Id
                    });
                    navEvt.fire();
                }else {
                    var url = '/'+c.get("v.recordId");
                    window.open(url, "_self");
                }
            }
        });
        $A.enqueueAction(a);
    },
    
    savePost : function(c, e, h){
        c.set("v.showSpinner",true);
        var msg = 'Fields marked as * are required';
        c.set("v.payment.ERP7__Posted_Date__c", c.get('v.today'));
        c.set("v.payment.ERP7__Posted__c",true);
        c.set("v.payment.ERP7__Refund_Amount__c",c.get("v.payment.ERP7__Total_Amount__c"));
        c.set("v.payment.ERP7__Refund__c",true);
        c.set("v.payment.ERP7__Bill__c",c.get("v.Bill.Id"));
        if(!$A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Purchase_Order__c'))) c.set("v.payment.ERP7__Purchase_Orders__c",c.get("v.Bill.ERP7__Purchase_Order__c"));
        
        var validation = true;
        if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Payment_Account__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Payment_Account__c'))){
            validation = false;
        }   
        if($A.util.isUndefinedOrNull(c.find("paymentAmount").get("v.value")) || $A.util.isEmpty(c.find("paymentAmount").get("v.value"))){
            c.find("paymentAmount").showHelpMessageIfInvalid();
            validation = false;
        }
        if(!$A.util.isUndefinedOrNull(c.find("checkReference")) && ($A.util.isUndefinedOrNull(c.find("checkReference").get("v.value")) || $A.util.isEmpty(c.find("checkReference").get("v.value")))){
            c.find("checkReference").showHelpMessageIfInvalid();
            validation = false;
        }
        
        if(c.get('v.payment.ERP7__Bank_Charges__c') > 0 && c.get('v.payment.ERP7__Bank_Charges__c') !='' && c.get('v.payment.ERP7__Bank_Charges__c') != undefined ){
            var total = parseInt(c.get('v.payment.ERP7__Bank_Charges__c')) + parseInt(c.get('v.payment.ERP7__Total_Amount__c'));
            if( total > c.get('v.dueAmount')){
                msg = 'Please Enter the proper amount';
                validation = false;
            }
            if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Bank_Fee_COA__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Bank_Fee_COA__c')))
            {
                validation = false;
            }
        }
        if(!validation){
            c.set("v.showSpinner",false);
            h.showToast('error','Error!', msg); 
            return;
        }
        
        var a = c.get("c.saveRefundPayment");
        a.setParams({payment:JSON.stringify(c.get("v.payment")),post:c.get('v.post'),
                     RType:c.get('v.RT'),accId : c.get("v.payment.ERP7__Accounts__c")
                    });
        a.setCallback(this,function(res){
            if(res.getState()==='SUCCESS'){
                c.set("v.showSpinner",false);
                var result = res.getReturnValue();
                var paymentName = res.getReturnValue().pay;
                c.set('v.PayName', paymentName.Name);
                h.showToast('Success','Success!',c.get('v.PayName')+' is created.');
                if(!$A.util.isUndefined(result['error'])){h.showToast('error','Error!',result['error']);return;}
                var navEvt = $A.get("e.force:navigateToSObject");
                if(!$A.util.isUndefined(navEvt)){
                    navEvt.setParams({
                        "recordId": ['payments'].Id
                    });
                    navEvt.fire();
                }else {
                    var url = '/'+c.get("v.recordId");
                    window.open(url, "_self");
                }
            }
        });
        $A.enqueueAction(a);
    }
})