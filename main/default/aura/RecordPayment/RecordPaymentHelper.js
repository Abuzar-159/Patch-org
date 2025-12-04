({
	showToast : function(type,title,Msg) {
        var toastEvt = $A.get("e.force:showToast");
        if(!$A.util.isUndefined(toastEvt)){
            toastEvt.setParams({"type":type,"title":title,"message":Msg});
            toastEvt.fire();
        }
	},
    showSpinner:function(c,e){
        c.set("v.showSpinner",true);
    },
    hideSpinner:function(c,e){
        c.set("v.showSpinner",false);
    },
    
    validation : function(c,e){
        var msg = 'Fields marked as * are required';
        if(c.get('v.post')){
            c.set("v.payment.ERP7__Posted_Date__c", c.get('v.today'));
        }else{
            c.set("v.payment.ERP7__Posted_Date__c",null);
        }
        c.find("invErrMsg").getElement().className="slds-hide";
        this.showSpinner(c,e);
        var validation = true;
        if(c.get('v.paymentMode')=='Cash' || c.get('v.paymentMode')=='Cheque/Wire'){
            if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Payment_Account__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Payment_Account__c')))
            {
                validation = false;
            }
        }   
        if($A.util.isUndefinedOrNull(c.find("vendorAccount").get("v.selectedRecordId")) || $A.util.isEmpty(c.find("vendorAccount").get("v.selectedRecordId")))
            validation = false;
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
            if( total > c.get('v.CustomerBalance')){
                msg = 'Please Enter the proper amount';
                validation = false;
            }
         if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Bank_Fee_COA__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Bank_Fee_COA__c')))
          {
           validation = false;
         }
        }
        var cbox = c.find('cbox');
        if(!$A.util.isUndefined(cbox) && $A.util.isUndefined(cbox.length)){
            if(!cbox.get("v.checked"))validation = false;
            }else if(c.get('v.setRT')!='Customer payment' && c.get('v.setRT')!='Debit_Note_Payments'){
            var flag = 0;
            for(var x in cbox){
                if(cbox[x].get("v.checked"))flag++;
            }
            if(!flag){validation = false;c.find("invErrMsg").getElement().className="slds-show";}
        }
        if(!validation){this.hideSpinner(c,e);this.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'), msg); return false}
        else return true;
    },
    
    validatePayment : function(cmp,event){
        var PaymentMethod=cmp.get("v.PaymentMethod");
        if(PaymentMethod.ERP7__Name_on_Card__c == '' || PaymentMethod.ERP7__Name_on_Card__c == undefined) {
            cmp.set("v.CardError", $A.get('$Label.c.Please_fill_Card_Holder_Name'));
            return false;
        }else if(PaymentMethod.ERP7__Card_Number__c == '' || PaymentMethod.ERP7__Card_Number__c == undefined) {
            cmp.set("v.CardError", $A.get('$Label.c.Please_fill_Card_Number'));
            return false;
        }else if(cmp.get("v.CVV") == '' || cmp.get("v.CVV") == undefined) {
            cmp.set("v.CardError", $A.get('$Label.c.Please_fill_CVV'));
            return false;
        }else if(cmp.get("v.OrgId") == '' || cmp.get("v.OrgId") == undefined){
            cmp.set("v.CardError", $A.get('$Label.c.Please_select_Organization'));
            return false;
        }else 
            return true;
        
            
    },
    
    applyCredit : function(c, e){
        console.log('Invoice:',c.get("v.Invoice"));
        console.log('Invoice:',JSON.stringify(c.get("v.Invoice")));
        console.log('creditNotes:',c.get("v.creditNotes"));
        var action=c.get("c.updateInvoiceCreditNotes");
            c.set("v.Invoice.ERP7__Credit_Note__c",c.get("v.cnAmount"));
            action.setParams({
                "cnList":c.get("v.creditNotes"),
                "inv":JSON.stringify(c.get("v.Invoice"))
            });
            action.setCallback(this,function(r){
                if(r.getState() === 'SUCCESS'){
                    this.showToast('Success',$A.get('$Label.c.Success'),$A.get('$Label.c.Credit_Applied_successfully'));
                    var url = '/'+c.get("v.Invoice.Id");
                    window.location.replace(url);
                }
            });
            $A.enqueueAction(action);
    },
    
    
    applyRefundCredit : function(c, e){
        console.log('Payment:',c.get("v.RefundPaymentId"));
        console.log('creditNotes:',c.get("v.creditNotes"));
        var action=c.get("c.updatePaymentCreditNotes");
            action.setParams({
                "cnList":c.get("v.creditNotes"),
                "payId":c.get("v.RefundPaymentId"),
                "payName":c.get('v.PayName')
            });
            action.setCallback(this,function(r){
                if(r.getState() === 'SUCCESS'){
                    this.showToast('Success',$A.get('$Label.c.Success'),$A.get('$Label.c.Credit_Applied_successfully'));
                    var url = '/'+c.get("v.RefundPaymentId");
                    window.location.replace(url);
                }
            });
            $A.enqueueAction(action);
    }
})