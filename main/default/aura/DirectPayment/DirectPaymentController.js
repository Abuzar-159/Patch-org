({
    doInit : function(cmp, event, helper) {
        var action = cmp.get("c.getDefaultOrganisation");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                cmp.set("v.OrgId",response.getReturnValue().Id);
            }  
        });
        $A.enqueueAction(action);  
        var vBillDate = new Date();
        vBillDate.setDate(vBillDate.getDate());
        cmp.set("v.payment.ERP7__Payment_Date__c", vBillDate.getFullYear() + "-" + (vBillDate.getMonth() + 1) + "-" + vBillDate.getDate());
    },
    
    addEntry : function(component, event, helper) {
        var expList = component.get("v.generalLedgerList");
        expList.unshift({sObjectType :'lederClass'});
        component.set("v.generalLedgerList", expList);
    },
    
    cancelCalled : function(component, event, helper) {
        history.back();
    },
    
    saveCalled : function(c, e, h) {
        c.set("v.showMmainSpin", true);
        if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Accounts__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Accounts__c'))){
            c.set("v.showMmainSpin", false);
            h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'),$A.get('$Label.c.PH1_please_select_the_vendor'));return;
        }
        
        if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Payment_Account__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Payment_Account__c'))){
            c.set("v.showMmainSpin", false);
            h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'),$A.get('$Label.c.PH2_please_select_the_payment_account'));return;
        }
        if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Total_Amount__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Total_Amount__c'))){
            c.set("v.showMmainSpin", false);
            h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'),$A.get('$Label.c.PH7_please_Enter_the_payment_amount'));return;
        }
        if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Reference_Cheque_No__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Reference_Cheque_No__c'))){
            c.set("v.showMmainSpin", false);
            h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'),$A.get('$Label.c.PH3_please_Enter_the_reference_number'));return;
        }
        
        if($A.util.isUndefinedOrNull(c.get('v.generalLedgerList')) || $A.util.isEmpty(c.get('v.generalLedgerList'))){
            c.set("v.showMmainSpin", false);
            h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'),$A.get('$Label.c.PH4_please_Add_the_general_entries'));return;
        }
        
        var genList = c.get("v.generalLedgerList");
        var actualAmount = c.get("v.payment.ERP7__Total_Amount__c");
        var TotalAmount = 0.00;
        /*for(var i=0;i<genList.length;i++){
            TotalAmount = parseFloat(TotalAmount) + parseFloat(genList[i].ledger.ERP7__Debit_Entry__c) + parseFloat(genList[i].taxAmount);
        }*/
        TotalAmount = parseFloat(c.get("v.SubTotal")) + parseFloat(c.get("v.TaxAmount")); 
        if(actualAmount != TotalAmount){
            c.set("v.showMmainSpin", false);
            h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'),$A.get('$Label.c.PH5_General_entry_Amount_does_not_match_with_the_Total_Amount'));
            return;
        }
        
        var genList = c.get("v.generalLedgerList");
        for(var i=0;i<genList.length;i++){
            if($A.util.isUndefinedOrNull(genList[i].ledger.ERP7__Chart_of_Account__c) || $A.util.isEmpty(genList[i].ledger.ERP7__Chart_of_Account__c)){
                c.set("v.showMmainSpin", false);
            	h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'),$A.get('$Label.c.PH6_Please_select_the_Chart_of_Accounts'));
            	return;
            }
        }
        var a = c.get("c.savePayment");
        a.setParams({payment:JSON.stringify(c.get("v.payment")), accId : c.get("v.OrgId"), 'ledger':JSON.stringify(c.get("v.generalLedgerList")), 'TaxAmount' : c.get("v.TaxAmount")
                    });
        a.setCallback(this,function(res){
            if(res.getState()==='SUCCESS'){
                var result = res.getReturnValue();
                var paymentName = res.getReturnValue().pay;
                c.set('v.PayName', paymentName.Name);
                h.showToast('Success',$A.get('$Label.c.Success'),c.get('v.PayName')+$A.get('$Label.c.Is_Created'));
                if(!$A.util.isUndefined(result['error'])){h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'),result['error']);return;}
                var url = '/'+paymentName.Id;
                window.open(url, "_self");
            }
            c.set("v.showMmainSpin", false);
        });
        $A.enqueueAction(a);
    },
    
    updateDetails : function(c, e, h) {
        var genList = [];
        genList = c.get("v.generalLedgerList");
        var SubTotal = 0.00;
        var TaxAmount = 0.00;
        for(var i=0;i<genList.length;i++){
            if(!$A.util.isUndefinedOrNull(genList[i].ledger)){
                if(!$A.util.isUndefinedOrNull(genList[i].ledger.ERP7__Debit_Entry__c) || !$A.util.isEmpty(genList[i].ledger.ERP7__Debit_Entry__c)) SubTotal = parseFloat(SubTotal) + parseFloat(genList[i].ledger.ERP7__Debit_Entry__c);
                if(!$A.util.isUndefinedOrNull(genList[i].taxAmount) || !$A.util.isEmpty(genList[i].taxAmount)) TaxAmount = parseFloat(TaxAmount) + parseFloat(genList[i].taxAmount);
            }
        }
        c.set("v.SubTotal", SubTotal);
        c.set("v.TaxAmount", TaxAmount);
    },
    
    DeleteRecord : function(c, e, h)  { 
        var index = e.currentTarget.dataset.record;
        var genList = [];
        genList = c.get("v.generalLedgerList");
        genList.splice(index, 1);
        c.set("v.generalLedgerList",genList);
        $A.enqueueAction(c.get("c.updateDetails"));
    },
})